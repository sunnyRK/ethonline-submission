pragma solidity ^0.6.0;

import "./yieldpod.sol";
import "../helper/Ownable.sol";

//createpod kovan:  "0","10000","600","1","0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD","0x58ad4cb396411b691a9aab6f74545b2c5217fe6a","New Pod"

contract PodFactory is Ownable {
    address[] public podAddress;
    function createPod( 
        uint256 lendingChoice,
        uint256 minimum,
        uint256 timeStamp,
        uint256 totalWinner,
        address tokenAddress,
        address interestBearingToken,
        string memory betName
    ) public onlyOwner {
        yieldpod newYieldPod = new yieldpod(
            lendingChoice, 
            minimum,
            timeStamp, 
            totalWinner,
            tokenAddress, 
            interestBearingToken, 
            msg.sender,
            betName
        );
        podAddress.push(address(newYieldPod));
    }
    
    function getPods() public view returns (address[] memory){
        return podAddress;
    }
}
