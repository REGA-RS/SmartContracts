pragma solidity ^0.4.10;

import "./rstBase.sol";

contract RegaVoting is VotingControllerBase {
  enum votingResult {
    NotVoted,
    VotedFor,
    VotedAgainst
  }

  function voteFor() public {
    require( balanceOf[msg.sender] > 0 );
    getVotingData().registerVoting( msg.sender, votingResult.VotedFor, balanceOf[msg.sender] );
  }

  function voteAgainst() public {
    require( balanceOf[msg.sender] > 0 );
    getVotingData().registerVoting( msg.sender, votingResult.VotedAgainst, balanceOf[msg.sender] );
  }

  function startVoting( bytes32 description ) public {
    votingData = new RegaVotingData( description );
  }

  function stopVoting() public {
    getVotingData().stop();
    processVotingResult();
  }

  function getCurrentVotingDescription() public constant returns (bytes32 description) {
    return getVotingData().description();
  }

  function getVotingData() internal constant returns (RegaVotingData vd) {
    require( votingData != address(0x0) );
    return RegaVotingData(votingData);
  }

  function processVotingResult() internal {

  }
}

contract RegaVotingData {
  mapping (address => RegaVoting.votingResult) public votingResults;
  uint256 public votedFor;
  uint256 public votedAgainst;
  address public owner;
  bytes32  public description;
  bool    public isOpen;

  function RegaVotingData( bytes32 descr ) {
    description = descr;
    owner = msg.sender;
    isOpen = true;
  }

  function stop( ) {
    require( msg.sender == owner );
    isOpen = false;
  }

  function registerVoting( address voter, RegaVoting.votingResult vote, uint256 weight ) {
    require( msg.sender == owner && isOpen );
    if( votingResults[voter] == RegaVoting.votingResult.NotVoted &&
        vote != RegaVoting.votingResult.NotVoted &&
        weight > 0 ) {
      votingResults[voter] = vote;
      if( vote == RegaVoting.votingResult.VotedFor )
        votedFor += weight;
      else
        votedAgainst += weight;
    }
  }
}
