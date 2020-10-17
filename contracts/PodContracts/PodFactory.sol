pragma solidity ^0.6.0;

import "./yieldpod.sol";
import "../helper/Ownable.sol";

contract PodFactory is Ownable {
    address[] public podAddress;
    function createPod( 
        uint256 lendingChoice,
        uint256 minimum, 
        uint256 numstakers, 
        uint256 timeStamp, 
        address tokenAddress, 
        address interestBearingToken, 
        string memory betName
        
    ) public onlyOwner {
        yieldpod newYieldPod = new yieldpod(
            lendingChoice, 
            minimum, 
            numstakers, 
            timeStamp, 
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
