pragma solidity ^0.6.0;

import "../helper/Ownable.sol";
import "../helper/SafeMath.sol";
import "../NFTToken/PIGGYToken.sol";
import "../interfaces/storageInterface/IPodStorageInterface.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/aaveInterface/ILendingPoolAddressesProvider.sol";
import "../interfaces/aaveInterface/ILendingPool.sol";
import "../interfaces/aaveInterface/IAToken.sol";
import "../interfaces/aaveInterface/AaveCoreInterface.sol";
import "../interfaces/aaveInterface/ATokenInterface.sol";
import "../interfaces/compoundInterface/CErc20.sol";
import "../interfaces/yearnInterface/IYDAI.sol";

contract piggybank is Ownable {
    using SafeMath for uint256;
    address public devAddress;
    uint256 public constant DEV_FEE = 10;
    
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
    
    IPodStorageInterface public iPodStorageInterface;
    
    mapping(address => uint256[]) public stakersAllNft;
    mapping(uint256 => uint256) public piggyTobetIdmapping;
    
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    
    struct PIGGYPool {
        uint256 lastRewardBlock;
        uint256 accNftPerShare;
        uint256 rewardPerBlock;
        uint256 totalPoolBalance;
        uint256 allocPoint;
    }
    
    PIGGYPool[] public piggyPool;
    PIGGYTOKEN public piggyToken;
    uint256 public totalAllocPoint = 0;
    
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    
    constructor(
        PIGGYTOKEN _piggyToken,
        address _devAddress
    ) public {
        piggyToken = _piggyToken;
        devAddress = _devAddress;
        iPodStorageInterface = IPodStorageInterface(0x92FcfD8948D09B8be5852e88aAb53E99A414a192);
    }
    
    function piggyPoolLength() external view returns (uint256) {
        return piggyPool.length;
    }
    
    function addNewPod() public onlyOwner {
        piggyPool.push(PIGGYPool({
            lastRewardBlock: 0,
            accNftPerShare: 0,
            rewardPerBlock: 100,
            totalPoolBalance: 0,
            allocPoint: 0
        }));
    }
    
    function depositNFT(uint256 _pid, address staker, uint256 tokenId) public {
        stakersAllNft[staker].push(tokenId);
        PIGGYPool storage pool = piggyPool[_pid];
        UserInfo storage user = userInfo[_pid][staker];

        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accNftPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safePiggyTransfer(staker, pending);
            }
        }
        
        (, uint256 _amount, ) = iPodStorageInterface.getNftDetail(iPodStorageInterface.getBetIDForNFT(tokenId), staker);
        pool.totalPoolBalance = pool.totalPoolBalance.add(_amount);
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accNftPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }
    
    function withdrawNFT(uint256 _pid, address staker, uint256 tokenId) public {
        uint256 betId = iPodStorageInterface.getBetIDForNFT(tokenId);
        PIGGYPool storage pool = piggyPool[_pid];
        UserInfo storage user = userInfo[_pid][staker];
        (, uint256 _amount, ) = iPodStorageInterface.getNftDetail(betId, staker);
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accNftPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safePiggyTransfer(staker, pending);
        }
        
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accNftPerShare).div(1e12);
        pool.totalPoolBalance = pool.totalPoolBalance.sub(_amount);
        
        if(iPodStorageInterface.isInterestNFT(tokenId)){
            iPodStorageInterface.burnInterestNft(betId, staker);
        } else {
            iPodStorageInterface.burnNft(betId, staker);
        }
        
        (address regularToken, address lendingToken) = iPodStorageInterface.getBetTokens(betId); 
        
        if (iPodStorageInterface.getYieldMechanism(betId) == 0) {
            aaveRedeem(regularToken, _amount);
        } else if(iPodStorageInterface.getYieldMechanism(betId) == 1) {
            compoundRedeem(lendingToken, _amount);
        } else if(iPodStorageInterface.getYieldMechanism(betId) == 2) {
            yearnRedeem(lendingToken, _amount);
        }
        IERC20(regularToken).transfer(staker, _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }
    
    function withdrawAllNFT(uint256 _pid, address staker) public {
        uint256 betId;
        uint256[] memory tokenIDs = stakersAllNft[staker];
        PIGGYPool storage pool = piggyPool[_pid];
        UserInfo storage user = userInfo[_pid][staker];
        require(user.amount >= 0, "withdraw: not good");
        uint256 _amount =  user.amount;
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accNftPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safePiggyTransfer(staker, pending);
        }
        user.amount = 0;
        user.rewardDebt = user.amount.mul(pool.accNftPerShare).div(1e12);
        pool.totalPoolBalance = pool.totalPoolBalance.sub(_amount);
        for (uint i=0; i< tokenIDs.length; i++) {
            betId = iPodStorageInterface.getBetIDForNFT(tokenIDs[i]);
            
            if(iPodStorageInterface.isInterestNFT(tokenIDs[i])){
                iPodStorageInterface.burnInterestNft(betId, staker);
            } else {
                iPodStorageInterface.burnNft(betId, staker);
            }
            
            (address regularToken, address lendingToken) = iPodStorageInterface.getBetTokens(betId); 
        
            if (iPodStorageInterface.getYieldMechanism(betId) == 0) {
                aaveRedeem(regularToken, _amount);
            } else if(iPodStorageInterface.getYieldMechanism(betId) == 1) {
                compoundRedeem(lendingToken, _amount);
            } else if(iPodStorageInterface.getYieldMechanism(betId) == 2) {
                yearnRedeem(lendingToken, _amount);
            }
            IERC20(regularToken).transfer(staker, _amount);
        }
        
        emit Withdraw(msg.sender, _pid, _amount);
    }
    
    function updatePool(uint256 _pid) public {
        PIGGYPool storage pool = piggyPool[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        if (pool.totalPoolBalance == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 blocksToReward = block.number.sub(pool.lastRewardBlock);
        uint256 piggyReward = blocksToReward.mul(pool.rewardPerBlock);
        piggyToken.mint(devAddress, piggyReward.mul(DEV_FEE).div(100));
        piggyToken.mint(address(this), piggyReward);
        pool.accNftPerShare = pool.accNftPerShare.add(piggyReward.mul(1e12));
        pool.lastRewardBlock = block.number;
    }
    
    function pendingPiggy(uint256 _pid, address _staker) external view returns (uint256) {
        PIGGYPool storage pool = piggyPool[_pid];
        UserInfo storage user = userInfo[_pid][_staker];
        uint256 accNftPerShare = pool.accNftPerShare;
        uint256 lpSupply = pool.totalPoolBalance;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 blocksToReward = block.number.sub(pool.lastRewardBlock);
            uint256 piggyReward = blocksToReward.mul(pool.rewardPerBlock);
            accNftPerShare = accNftPerShare.add(piggyReward.mul(1e12));
        }
        return user.amount.mul(accNftPerShare).div(1e12).sub(user.rewardDebt);
    }
    
    function safePiggyTransfer(address _to, uint256 _amount) internal {
        uint256 balance = piggyToken.balanceOf(address(this));
        if (_amount > balance) {
            piggyToken.transfer(_to, balance);
        } else {
            piggyToken.transfer(_to, _amount);
        }
    }
    
    function massUpdatePools() public {
        uint256 length = piggyPool.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }
    
    function aaveDeposit(address _regularToken, uint256 amount) internal {
        address aaveLendingPoolAddressesProvider = 0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5;
        aaveProvider = ILendingPoolAddressesProvider(aaveLendingPoolAddressesProvider);
        aaveLendingPool = ILendingPool(aaveProvider.getLendingPool());
        aaveCore = AaveCoreInterface(aaveProvider.getLendingPoolCore());
        atoken = ATokenInterface(aaveCore.getReserveATokenAddress(address(_regularToken)));
        aaveLendingPool.deposit(address(_regularToken), amount, referral);
    }
    
    function compoundDeposit(address _lendingAddress, uint256 amount) internal {
        cToken = CErc20(_lendingAddress);
        cToken.mint(amount);
    }
    
    function yearnDeposit(address _lendingAddress, uint256 amount) internal {
        yDai = IYDAI(_lendingAddress);  // Mainnet: 0xACd43E627e64355f1861cEC6d3a6688B31a6F952 
        yDai.deposit(amount);
    }
    
    function aaveRedeem(address _regularToken, uint256 amount) internal {
        address aaveLendingPoolAddressesProvider = 0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5;
        aaveProvider = ILendingPoolAddressesProvider(aaveLendingPoolAddressesProvider);
        aaveLendingPool = ILendingPool(aaveProvider.getLendingPool());
        aaveCore = AaveCoreInterface(aaveProvider.getLendingPoolCore());
        atoken = ATokenInterface(aaveCore.getReserveATokenAddress(address(_regularToken)));
        atoken.redeem(amount);
    }
    
    function compoundRedeem(address _lendingAddress, uint256 amount) internal {
        cToken = CErc20(_lendingAddress);
        cToken.redeem(amount);
    }
    
    function yearnRedeem(address _lendingAddress, uint256 amount) internal {
        yDai = IYDAI(_lendingAddress);  // Mainnet: 0xACd43E627e64355f1861cEC6d3a6688B31a6F952 
        yDai.withdraw(amount);
    }
}