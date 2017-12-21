pragma solidity ^0.4.10;

import "./erc20token.sol";
import "./interfaces/iapplypreico.sol";
import "./preICOToken.sol";

contract RSTBase is ERC20Token {
  address public board;
  address public owner;

  address public votingData;
  address public tokenData;
  address public feesData;

  uint256 public reserve;
  uint32  public crr;         // per cent
  uint256 public weiForToken; // current rate
  uint8   public totalAccounts;

  modifier boardOnly() {
    require(msg.sender == board);
    _;
  }
}

contract TokenControllerBase is RSTBase {
  function init() public;
  function isSellOpen() public constant returns(bool);
  function isBuyOpen() public constant returns(bool);
  function sell(uint value) public;
  function buy() public payable;
  function addToReserve() public payable;
}

contract VotingControllerBase is RSTBase {
  function voteFor() public;
  function voteAgainst() public;
  function startVoting() public;
  function stopVoting() public;
  function getCurrentVotingDescription() public constant returns (bytes32 vd) ;
}

contract FeesControllerBase is RSTBase {
  function init() public;
  function withdrawFee() public;
  function calculateFee() public;
  function addPayee( address payee ) public;
  function removePayee( address payee ) public;
  function setRepayment( ) payable public;
}
