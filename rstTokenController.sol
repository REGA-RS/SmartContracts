pragma solidity ^0.4.10;

import "./rstBase.sol";

contract RSTTokenController is TokenControllerBase {
  function init() public {
    tokenData = new RSTTokenData(this);
  }
  function isSellOpen() public constant returns(bool) {
    return getTokenData().sellOpen();
  }
  function isBuyOpen() public constant returns(bool) {
    return getTokenData().buyOpen();
  }
  function sell(uint value) public;
  function buy() public payable;
  function addToReserve() public payable;

  function getTokenData() internal constant returns (RSTTokenData td) {
    require(tokenData != address(0));
    return RSTTokenData(tokenData);
  }
}

contract RSTTokenData {
  RSTBase public owner;
  bool public sellOpen;
  bool public buyOpen;

  function RSTTokenData( RSTBase _owner ) {
    owner = _owner;
    sellOpen = false;
    buyOpen = false;
  }
}
