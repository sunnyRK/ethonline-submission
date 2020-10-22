pragma solidity ^0.6.0;

interface IPiggyInterface {
    function addNewPod() external;
    function depositNFT(uint256 _pid, address staker, uint256 tokenId) external;
    function withdrawNFT(uint256 _pid, address staker, uint256 tokenId) external;
    function withdrawAllNFT(uint256 _pid, address staker) external;
}