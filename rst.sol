pragma solidity ^0.4.10;

import "./rstBase.sol";

contract RiskSharingToken is RSTBase {
  string public constant version = "0.1";
  string public constant name = "REGA Risk Sharing Token";
  string public constant symbol = "RST";
  uint8 public constant decimals = 10;

  TokenControllerBase public tokenController;
  VotingControllerBase public votingController;

  modifier ownerOnly() {
    require( msg.sender == owner );
    _;
  }

  modifier boardOnly() {
    require( msg.sender == board );
    _;
  }

  function RiskSharingToken( address _board ) {
    board = _board;
    owner = msg.sender;
    tokenController = TokenControllerBase(0);
    votingController = VotingControllerBase(0);
    weiForToken = uint(10)**(18-1-decimals); // 0.1 Ether
    reserve = 0;
    crr = 20;
    totalAccounts = 0;
  }

  function() payable {

  }

  function setTokenController( TokenControllerBase tc, address _tokenData ) public boardOnly {
    tokenController = tc;
    if( _tokenData != address(0) )
      tokenData = _tokenData;
    if( tokenController != TokenControllerBase(0) )
      if( !tokenController.delegatecall(bytes4(sha3("init()"))) )
        revert();
  }

// Voting
  function setVotingController( VotingControllerBase vc ) public boardOnly {
    votingController = vc;
  }

  function startVoting( bytes32 /*description*/ ) public boardOnly validAddress(votingController) {
    if( !votingController.delegatecall(msg.data) )
      revert();
  }

  function stopVoting() public boardOnly validAddress(votingController) {
    if( !votingController.delegatecall(msg.data) )
      revert();
  }

  function voteFor() public validAddress(votingController) {
    if( !votingController.delegatecall(msg.data) )
      revert();
  }

  function voteAgainst() public validAddress(votingController) {
    if( !votingController.delegatecall(msg.data) )
      revert();
  }

// Tokens operations
  function buy() public payable validAddress(tokenController) {
    if( !tokenController.delegatecall(msg.data) )
      revert();
  }

  function sell( uint /*value*/ ) public validAddress(tokenController) {
    if( !tokenController.delegatecall(msg.data) )
      revert();
  }

  function addToReserve( ) public payable validAddress(tokenController) {
    if( !tokenController.delegatecall(msg.data) )
      revert();
  }

// some amount ma be not the reserve
  function withdraw( uint256 amount ) public boardOnly {
    require(safeSub(this.balance, amount) >= reserve);
    board.transfer( amount );
  }

  function issueToken( address holder, uint256 amount ) public ownerOnly {
    issueInternal(holder, amount);
  }

  uint256 constant D160 = 0x0010000000000000000000000000000000000000000;
  uint256 constant minGas = 100;

  function issueTokens( uint256[] data ) public ownerOnly {
    for (uint i=0; i<data.length; i++) {
      if( msg.gas < minGas )
        break;
      address a = address( data[i] & (D160-1) );
      uint amount = data[i] / D160;
      issueInternal(a, amount);
    }
  }

  function issueInternal( address holder, uint256 amount ) internal {
    reserve = safeAdd(reserve, amount * weiForToken * crr / 100);
    require( reserve <= this.balance );
    if (balanceOf[holder] == 0) {
        balanceOf[holder] = amount;
        totalSupply += amount;
        totalAccounts ++;
    }
  }
}
