pragma solidity ^0.6.0;

interface IYDAI {
  function deposit(uint _amount) external;
  function withdraw(uint _amount) external;
  function balanceOf(address _address) external view returns(uint);
  function getPricePerFullShare() external view returns(uint);
}