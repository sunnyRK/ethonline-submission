pragma solidity ^0.6.0;

interface IPodStorageInterface {
    function setBetIDManager(uint256 betId, address manager) external;
    function getBetIdManager(uint256 betId) external view returns(address);

    function setRunningPodBetId(uint256 betId) external;
    function getRunningPodBetId() external view returns(uint256);

    function addNewBetId(uint256 betId, address manager) external;
    function getBetIdArrayOfManager(address manager) external view returns(uint256[] memory);
    function getLengthOfBetIds(address manager) external view returns(uint256);
    
    function addNewBetIdForStaker(uint256 betId, address staker) external;
    function getBetIdArrayOfStaker(address staker) external view returns(uint256[] memory);
    function getLengthOfStakerBetIds(address staker) external view returns(uint256);

    function setBetIDOnConstructor(
        uint256 betId, 
        uint256 minimumContribution, 
        uint256 _yieldMechanism,
        string calldata betName
    ) external;
    function getMinimumContribution(uint256 betId) external view returns(uint256);
    function getPodName(uint256 betId) external view returns(string memory);
    function getYieldMechanism(uint256 betId) external view returns(uint256);
    
    function setWinnerDeclare(uint256 betId) external;
    function getWinnerDeclare(uint256 betId) external view returns(bool);
    function setInterest(uint256 betId, uint256 interest) external;
    function getInterest(uint256 betId) external view returns(uint256);
    
    function setSingleWinnerAddress(uint256 betId, uint256 winnerIndex) external;
    function setMultipleWinnerAddress(uint256 betId, uint256[] calldata winnerIndexes) external;
    function setWinnerNumbers(uint256 betId, uint256 winnigNumber) external;
    function isSingleOrMultipleWinner(uint256 betId) external view returns(uint256);
    function getSingleWinnerAddress(uint256 betId) external view returns(uint256);
    function getMultipleWinnerAddress(uint256 betId) external view returns(uint256[] memory);
    function setTotalWinner(uint256 betId, uint256 totalWinner) external;
    function getTotalWinner(uint256 betId) external view returns(uint256);
    
    function setTimestamp(uint256 betId, uint256 timestamp) external;
    function getTimestamp(uint256 betId) external view returns(uint256);

    function increaseStakerCount(uint256 betId) external;
    function decreaseStakerCount(uint256 betId) external;
    function getStakeCount(uint256 betId) external view returns(uint256);

    function setStakeforBet(uint256 betId, uint256 amount, address staker) external;
    function getStakeforBet(uint256 betId, address staker) external view returns(uint256);
    
    function addAmountInTotalStake(uint256 betId, uint256 amount) external;
    function subtractAmountInTotalStake(uint256 betId, uint256 amount) external;
    function getTotalStakeFromBet(uint256 betId) external view returns(uint256);

    function setNewStakerForBet(uint256 betId, address staker) external;
    function getStakersArrayForBet(uint256 betId) external view returns(address[] memory);
    function getLengthOfStakersARray(uint256 betId) external view returns(uint256);
    function getWinnerAddressByIndex(uint256 _betId, uint256 _index) external view returns(address);
    
    function setBetTokens(uint256 betId, address _tokenAddress, address _aaveToken) external;
    function getBetTokens(uint256 betId) external view returns(address, address);
    function setTotalWinning(address _staker, uint256 _winningAmount) external;
    function getTotalWinning(address _staker) external view returns(uint256);
    
    function setRedeemFlagStakerOnBet(uint256 betId, address staker) external;
    function setRevertRedeemFlagStakerOnBet(uint256 betId, address staker) external;
    function getRedeemFlagStakerOnBet(uint256 betId, address staker) external view returns(bool);
    
    function mintNft(uint256 betId, uint256 price, address staker) external;
    function mintInterestNft(uint256 betId, uint256 price, uint256 tokenId, address staker) external;
    function burnNft(uint256 betId, address staker) external;
    function burnInterestNft(uint256 betId, address staker) external;
    function getNftDetail(uint256 betId, address staker) external view returns(uint256, uint256, bool);
    function getInterestNftDetail(uint256 betId, address staker) external view returns(uint256, uint256, bool);
    function getBetIDForNFT(uint256 tokenId) external view returns(uint256);
}
