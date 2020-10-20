pragma solidity ^0.6.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract InstNFT is ERC721("InstCryp", "ICRYP") {
    
    address public owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier isOwner {
        require(owner == msg.sender);
        _;
    }
    
    function _safeMints(address to, uint256 _tokenId) public {
        _safeMint(to, _tokenId);
    }
    
    function _safeBurns(uint256 _tokenId) public {
        _burn(_tokenId);
    }
    
    function transferOwnership(address newOwner) public {
        owner = newOwner;
    }
}