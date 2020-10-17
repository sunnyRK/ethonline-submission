pragma solidity ^0.6.0;

import "../helper/SafeMath.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/aaveInterface/ILendingPoolAddressesProvider.sol";
import "../interfaces/aaveInterface/ILendingPool.sol";
import "../interfaces/aaveInterface/IAToken.sol";
import "../interfaces/aaveInterface/AaveCoreInterface.sol";
import "../interfaces/aaveInterface/ATokenInterface.sol";
import "../interfaces/compoundInterface/CErc20.sol";
import "../interfaces/yearnInterface/IYDAI.sol";
import "../interfaces/chainlinkInterface/IchainlinkAlarm.sol";
import "../interfaces/storageInterface/IPodStorageInterface.sol";
import "../storage/podStorage.sol";
import "./PodFactory.sol";

contract yieldpod {
    
    using SafeMath for uint256;
    uint256 public nonce = 0;
    uint256 public winnerNumber;
    uint256 public lendingChoice;
    
    // Aave contracts
    ILendingPoolAddressesProvider aaveProvider;
    ILendingPool aaveLendingPool;
    IAToken aTokenInstance;
    uint16 constant private referral = 0;
    ATokenInterface public atoken;
    AaveCoreInterface public aaveCore;
    
    // yearn
    IYDAI public yDai;

    // compound
    CErc20 public cToken;
    
    IERC20 public regularToken;
    IERC20 public lendingToken; // AAVE || yearn || Compound

    IPodStorageInterface iPodStorageInterface;
    
    IchainlinkAlarm iChainlinkAlarm;

    // Events
    event Deposit(uint256 amount, address indexed user, address indexed tokenAddress);
    event WinnerDeclare(uint256 _betId, uint256 interest, address indexed user);
    event WithDraw(uint256 _betId, uint256 amount, address indexed user, address indexed tokenAddress);

    constructor(uint256 _lendingChoice, uint256 _minimumVal, uint256 _numOfStakers, uint256 timeStamp, 
        address _tokenAddress, address _lendingAddress, address _podManager, string memory _betName) 
        public 
    {
        lendingChoice = _lendingChoice;
        iPodStorageInterface = IPodStorageInterface(0x9cc2dD17f25Fa44f6fF85Be918bB886C00902369);
        regularToken = IERC20(_tokenAddress);
        lendingToken = IERC20(_lendingAddress);
        
        uint256 betId = now;
        
        iPodStorageInterface.setBetTokens(betId, _tokenAddress, _lendingAddress);
        iPodStorageInterface.setBetIDManager(betId, _podManager);
        iPodStorageInterface.setBetIDOnConstructor(betId, _minimumVal, _numOfStakers, 0, _betName);
        iPodStorageInterface.addNewBetId(betId, _podManager);
        iPodStorageInterface.setTimestamp(betId, timeStamp);
        iPodStorageInterface.setRunningPodBetId(betId);
        
        if (lendingChoice == 0) {
            address aaveLendingPoolAddressesProvider = 0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5;
            aaveProvider = ILendingPoolAddressesProvider(aaveLendingPoolAddressesProvider);
            aaveLendingPool = ILendingPool(aaveProvider.getLendingPool());
            aaveCore = AaveCoreInterface(aaveProvider.getLendingPoolCore());
            atoken = ATokenInterface(aaveCore.getReserveATokenAddress(address(regularToken)));
        } else if(lendingChoice == 1) {
            cToken = CErc20(_lendingAddress);
        } else if(lendingChoice == 2) {
            yDai = IYDAI(_lendingAddress);  // Mainnet: 0xACd43E627e64355f1861cEC6d3a6688B31a6F952 
        }
        
        iChainlinkAlarm = IchainlinkAlarm(0x347baFf15492455b82316F4a8f8D431152f21cCB);
        iChainlinkAlarm.delayStart(0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e, "a7ab70d561d34eb49e9b1612fd2e044b", timeStamp);
    }
    
    function addStakeOnBet(uint256 _betId, uint256 amount) public {
        require(!iPodStorageInterface.getStakingDone(_betId) && !iPodStorageInterface.getWinnerDeclare(_betId), "No more space for stakers");            
        require(iPodStorageInterface.getMinimumContribution(_betId) <= amount, "Amount should be greater or equal to minimumContribution");
        
        uint256 numStakers = iPodStorageInterface.getNumOfStakers(_betId);
        iPodStorageInterface.setNewStakerForBet(_betId, msg.sender);
        iPodStorageInterface.increaseStakerCount(_betId);

        if(numStakers == iPodStorageInterface.getStakeCount(_betId)) {
            iPodStorageInterface.setStakingDone(_betId); ////After true, no more stakers will be accepted
        }
        
        iPodStorageInterface.setStakeforBet(_betId, amount, msg.sender);
        iPodStorageInterface.addAmountInTotalStake(_betId, amount);
        
        // address daiAddress = address(0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD); // kovan DAI
        regularToken.transferFrom(msg.sender, address(this), amount);
        
        if (lendingChoice == 0) {
            regularToken.approve(aaveProvider.getLendingPoolCore(), amount);
            aaveLendingPool.deposit(address(regularToken), amount, referral);
        } else if(lendingChoice == 1) {   
            regularToken.approve(address(lendingToken), amount);
            cToken.mint(amount);
        } else if(lendingChoice == 2) {
            regularToken.approve(address(yDai), amount);
            yDai.deposit(amount);
        }        
        emit Deposit(amount, msg.sender, address(regularToken));
    }
    
    function disburseAmount(uint256 _betId) public {
        require(!iPodStorageInterface.getWinnerDeclare(_betId) && iPodStorageInterface.getWinnerAddress(_betId) != address(0), "Winner declare and bet is expired.");
        require(iPodStorageInterface.getStakeCount(_betId) == iPodStorageInterface.getNumOfStakers(_betId), "Stakers is not full.");
        // require(now > iPodStorageInterface.getTimestamp(_betId), "Timstamp is not crossed.");
        
        if (lendingChoice == 0) {
            atoken.redeem(getBalanceofLendingToken(address(this)));
        } else if(lendingChoice == 1) {
            cToken.redeem(getBalanceofLendingToken(address(this)));
        } else if(lendingChoice == 2) {
            yDai.withdraw(getBalanceofLendingToken(address(this)));
        }  
        
        address winnerAddress = iPodStorageInterface.getWinnerAddress(_betId);
        uint256 interest = getBalanceofRegularToken(address(this)).sub(iPodStorageInterface.getTotalStakeFromBet(_betId));
        address[] memory stakers = iPodStorageInterface.getStakersArrayForBet(_betId);
        for(uint i=0; i<stakers.length; i++) {
            if(!iPodStorageInterface.getRedeemFlagStakerOnBet(_betId, stakers[i])) {
                if(winnerAddress != stakers[i]) {
                    regularToken.transfer(stakers[i], iPodStorageInterface.getStakeforBet(_betId, stakers[i]));
                } else {
                    regularToken.transfer(stakers[i], iPodStorageInterface.getStakeforBet(_betId, stakers[i]).add(interest));
                }   
            }
        }
        iPodStorageInterface.setWinnerDeclare(_betId);
        iPodStorageInterface.setWinnerAddress(_betId, winnerAddress);
        emit WinnerDeclare(_betId, interest, winnerAddress);
    }

    function redeemFromBetBeforeFinish(uint256 _betId) public  {
        require(!iPodStorageInterface.getWinnerDeclare(_betId) && 
            !iPodStorageInterface.getRedeemFlagStakerOnBet(_betId, msg.sender), 
            "Winner declare and bet is expired"
        );
        
        iPodStorageInterface.setRedeemFlagStakerOnBet(_betId, msg.sender);
        iPodStorageInterface.subtractAmountInTotalStake(_betId, iPodStorageInterface.getStakeforBet(_betId, msg.sender));
        iPodStorageInterface.decreaseStakerCount(_betId);

        aaveCore = AaveCoreInterface(aaveProvider.getLendingPoolCore());
        atoken = ATokenInterface(aaveCore.getReserveATokenAddress(address(regularToken)));
        
        if (lendingChoice == 0) {
            atoken.redeem(iPodStorageInterface.getStakeforBet(_betId, msg.sender));
        } else if(lendingChoice == 1) {
            cToken.redeem(iPodStorageInterface.getStakeforBet(_betId, msg.sender));
        } else if(lendingChoice == 2) {
            yDai.withdraw(iPodStorageInterface.getStakeforBet(_betId, msg.sender));
        }  
        
        regularToken.transfer(msg.sender, iPodStorageInterface.getStakeforBet(_betId, msg.sender));
        emit WithDraw(_betId, iPodStorageInterface.getStakeforBet(_betId, msg.sender), msg.sender, address(regularToken));
    }
    
    function getBalanceofLendingToken(address _owner) public view returns(uint256) {
        return lendingToken.balanceOf(_owner);
    }
    
    function getBalanceofRegularToken(address _owner) public view returns(uint256) {
        return regularToken.balanceOf(_owner);
    }
}