pragma solidity 0.6.6;

import "github.com/smartcontractkit/chainlink/blob/develop/evm-contracts/src/v0.6/VRFConsumerBase.sol";
import "../interfaces/storageInterface/IPodStorageInterface.sol";

contract ChainlinkVRF is VRFConsumerBase {
    
    uint256[] public vrfAllResults;
    bytes32 internal keyHash;
    uint256 internal fee;
    IPodStorageInterface public iPodStorageInterface;

    event WinnerDecided(uint256 _betId, address indexed winner);

    constructor() 
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
        ) public
    {
        iPodStorageInterface = IPodStorageInterface(0xB9F97358877022a8e02661469f8eC9832d408FF3);
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10 ** 18; // 0.1 LINK
    }

    function setPodStorageAddress(address podStorageAddress) public {
        iPodStorageInterface = IPodStorageInterface(podStorageAddress);
    }
    
    function requestRandomnesses() public returns (bytes32 requestId){
        uint256 seed = 1000; 
        requestId =requestRandomness(keyHash, fee, seed);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        uint256 _betId = iPodStorageInterface.getRunningPodBetId();
        
        // VRF randomness result
        uint256 vrfWinnerResult;

        // Get the participants array
        address[] memory stakerArray = iPodStorageInterface.getStakersArrayForBet(_betId);

        // if(iPodStorageInterface.isSingleOrMultipleWinner(_betId) == 0) {
            vrfWinnerResult = randomness.mod(iPodStorageInterface.getLengthOfStakersARray(_betId)); // Simplified example
            iPodStorageInterface.setSingleWinnerAddress(_betId, vrfWinnerResult);
        // } else if (iPodStorageInterface.isSingleOrMultipleWinner(_betId) == 1) {
        //     uint256 totalWinner = iPodStorageInterface.getTotalWinner(_betId);
        //     vrfWinnerResult = randomness.mod(totalWinner); // Simplified example
        //     iPodStorageInterface.setWinnerAddress(_betId, stakerArray[vrfWinnerResult]);
        // }
        vrfAllResults.push(vrfWinnerResult);

        // Winner declare event emit
        // emit WinnerDecided(_betId, stakerArray[vrfWinnerResult]);
    }
    
    function getWinnerRandomness() public view returns (uint256 vrfAllResult) {
        return vrfAllResults[vrfAllResults.length.sub(1)];
    }
}