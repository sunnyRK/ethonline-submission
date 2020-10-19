pragma solidity ^0.6.0;

import "../helper/SafeMath.sol";
    
contract podStorage {
    
    using SafeMath for uint256;
    uint256 public runningPodBetId;
    
    enum YieldMechanism { AAVE, COMPOUND, YIELD_FARMING }
    enum WinnigNumbers { SINGLE_WINNER, MULTIPLE_WINNER }
    
    struct betInfo {
        uint256 betId;
        uint256 minimumContribution;
        uint256 stakerCount;
        uint256 totalWinner;
        bool isWinnerDeclare; 
        string betName;
        YieldMechanism yieldMechanism; 
        WinnigNumbers winnigNumbers;
    }
    
    struct betTokens {
        address tokenAddress;
        address lendingToken;
    }
    
    mapping(uint256 => betInfo) public betInfoMapping;
    mapping(uint256 => betTokens) public betIdTokensMapping;
    mapping(uint256 => uint256) public singleWinner;
    mapping(uint256 => uint256[]) public multipleWinner;
    mapping(uint256 => uint256) public timeStamp;
    mapping(uint256 => address) public betIdMapping;
    mapping(address => uint256[]) public betIdsOfManager;
    mapping(uint256 => mapping(address => uint256)) public stakeOnBetId;
    mapping(uint256 => uint256) public totalValueOnBet;
    mapping(uint256 => address[]) public stakersOfBet;
    mapping(uint256 => mapping(address => bool)) isRedeem;
    
    function setBetIDManager(uint256 betId, address manager) public {
        betIdMapping[betId] = manager;
    }
    
    function getBetIdManager(uint256 betId) public view returns(address) {
        return betIdMapping[betId];
    }
    
    function setRunningPodBetId(uint256 betId) public {
        runningPodBetId = betId;
    }
    
    function getRunningPodBetId() public view returns(uint256) {
        return runningPodBetId;
    }
    
    function addNewBetId(uint256 betId, address manager) public {
        betIdsOfManager[manager].push(betId);
    }
    
    function getBetIdArrayOfManager(address manager) public view returns(uint256[] memory) {
        return betIdsOfManager[manager];
    }
    
    function getLengthOfBetIds(address manager) public view returns(uint256) {
        return betIdsOfManager[manager].length;
    }
    
    function setBetIDOnConstructor(
        uint256 betId, 
        uint256 minimumContribution, 
        uint256 _yieldMechanism,
        string memory betName
    ) public {
        betInfoMapping[betId].minimumContribution = minimumContribution;
        betInfoMapping[betId].betName = betName;
        betInfoMapping[betId].yieldMechanism = YieldMechanism(_yieldMechanism);
    }
    
    function getMinimumContribution(uint256 betId) public view returns(uint256) {
        return betInfoMapping[betId].minimumContribution;
    }
    
    function getPodName(uint256 betId) public view returns(string memory) {
        return betInfoMapping[betId].betName;
    }
    
    function getYieldMechanism(uint256 betId) public view returns(uint256) {
        return uint(betInfoMapping[betId].yieldMechanism);
    }
    
    function setWinnerDeclare(uint256 betId) public {
        betInfoMapping[betId].isWinnerDeclare = true;
    }
    
    function getWinnerDeclare(uint256 betId) public view returns(bool) {
        return betInfoMapping[betId].isWinnerDeclare;
    }
    
    function setSingleWinnerAddress(uint256 betId, uint256 winnerIndex) public {
        require(isSingleOrMultipleWinner(betId) == 0);
        singleWinner[betId] = winnerIndex;
    }
    
    function setMultipleWinnerAddress(uint256 betId, uint256[] memory winnerIndexes) public {
        require(isSingleOrMultipleWinner(betId) == 1);
        for (uint256 i = 0; i < winnerIndexes.length; i++) {
            multipleWinner[betId].push(winnerIndexes[i]);
        }
    }

    function isSingleOrMultipleWinner(uint256 betId) public view returns(uint256) {
        return uint(betInfoMapping[betId].winnigNumbers);
    }
    
    function getSingleWinnerAddress(uint256 betId) public view returns(uint256) {
        return singleWinner[betId];
    }
    
    function getMultipleWinnerAddress(uint256 betId) public view returns(uint256[] memory) {
        return multipleWinner[betId];
    }
        
    function setTimestamp(uint256 betId, uint256 timestamp) public {
        timeStamp[betId] = now.add(timestamp.mul(86400));
    }
    
    function getTimestamp(uint256 betId) public view returns(uint256) {
        return timeStamp[betId];
    }

    function increaseStakerCount(uint256 betId) public {
        betInfoMapping[betId].stakerCount = betInfoMapping[betId].stakerCount.add(1);
    }
    
    function decreaseStakerCount(uint256 betId) public {
        betInfoMapping[betId].stakerCount = betInfoMapping[betId].stakerCount.sub(1);
    }
    
    function getStakeCount(uint256 betId) public view returns(uint256) {
        return betInfoMapping[betId].stakerCount;
    }

    function setStakeforBet(uint256 betId, uint256 amount, address staker) public {
        stakeOnBetId[betId][staker] = amount;
    }
    
    function getStakeforBet(uint256 betId, address staker) public view returns(uint256) {
        return stakeOnBetId[betId][staker];
    }
    
    function addAmountInTotalStake(uint256 betId, uint256 amount) public {
        totalValueOnBet[betId] = totalValueOnBet[betId].add(amount);
    }
    
    function subtractAmountInTotalStake(uint256 betId, uint256 amount) public {
        totalValueOnBet[betId] = totalValueOnBet[betId].sub(amount);
    }
    
    function getTotalStakeFromBet(uint256 betId) public view returns(uint256) {
        return totalValueOnBet[betId];
    }
    
    function setNewStakerForBet(uint256 betId, address staker) public {
        stakersOfBet[betId].push(staker);
    }
    
    function getStakersArrayForBet(uint256 betId) public view returns(address[] memory){
        return stakersOfBet[betId];
    }
    
    function getLengthOfStakersARray(uint256 betId) public view returns(uint256) {
        return stakersOfBet[betId].length;
    }
    
    function setBetTokens(uint256 betId, address _tokenAddress, address _lendingToken) public {
        betIdTokensMapping[betId].tokenAddress = _tokenAddress;
        betIdTokensMapping[betId].lendingToken = _lendingToken;
    }
    
    function getBetTokens(uint256 betId) public view returns(address, address){
        return (
            betIdTokensMapping[betId].tokenAddress,
            betIdTokensMapping[betId].lendingToken
        ); 
    }
    
    function setRedeemFlagStakerOnBet(uint256 betId, address staker) public {
        isRedeem[betId][staker] = true;
    }
    
    function setRevertRedeemFlagStakerOnBet(uint256 betId, address staker) public {
        isRedeem[betId][staker] = false;
    }
    
    function getRedeemFlagStakerOnBet(uint256 betId, address staker) public view returns(bool) {
        return isRedeem[betId][staker];
    }
}