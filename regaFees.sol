pragma solidity ^0.4.10;

import "./rstBase.sol";

contract RegaFees is FeesControllerBase {
  struct repaymentStatus {
    bool  payee;
    uint32 lastPaidPeriod;
    uint32 fromPeriod;
    uint256 share;  // payee share (number of tokens)
    uint256 forWithdrawal;
  }
  struct repayment {
    uint256 amount;       // sum of wei for this repayment
    uint256 payeesAmount; // sum of payees tokens amounts
    uint32  numberOfPayees;
    uint256 paidOut;  // sum already paid out
  }
  function withdrawFee() public {
    RegaFeesData(feesData).withdrawFee(msg.sender);
  }

  function calculateFee() public {
    RegaFeesData(feesData).calculateFee(msg.sender);
  }

  function addPayee( address payee ) public boardOnly {
    RegaFeesData(feesData).addPayee(payee);
  }

  function removePayee( address payee ) public boardOnly {
    RegaFeesData(feesData).removePayee(payee);
  }

  function setRepayment( ) payable public {
    feesData.transfer(msg.value);
  }

  function init() {
    feesData = new RegaFeesData( board );
  }

}

contract RegaFeesData {
  mapping (address => RegaFees.repaymentStatus) public payees;
  RegaFees.repayment[] public repayments;
  uint32 public currentPeriod;
  uint256 public payeesAmount; // sum of payees tokens amounts
  uint32  public numberOfPayees;
  RSTBase public owner;
  address public regaBoard;

  modifier allowed() {
    require(msg.sender == address(owner) || msg.sender == regaBoard);
    _;
  }
  function RegaFeesData( address rb ) {
    regaBoard = rb;
    owner = RSTBase(msg.sender);
    currentPeriod = 1;
  }

  function() payable {

    if( msg.value > 0 ) {
      repayments.push(RegaFees.repayment({amount:msg.value,payeesAmount:payeesAmount,numberOfPayees:numberOfPayees,paidOut:0}));
      currentPeriod ++;
    }
  }

  function removePayee( address payee ) allowed {
    if( payees[payee].payee ) {
      payees[payee].payee = false;
      numberOfPayees --;
      payeesAmount -= payees[payee].share;
    }
  }

  function addPayee( address payee ) allowed {
    if( !payees[payee].payee ) {
      payees[payee] = RegaFees.repaymentStatus(
        {payee:true, lastPaidPeriod: currentPeriod,
        fromPeriod: currentPeriod, share:getPayeeAmount(payee),
        forWithdrawal: 0});
      numberOfPayees ++;
      payeesAmount += getPayeeAmount(payee);
    }
  }

  function calculateFee( address payee ) public {
    uint256 sum;
    uint256 periodAmount;
    uint32 period;
    RegaFees.repaymentStatus storage payeeStatus = payees[payee];
    if( payeeStatus.payee ) {
      for( period = payeeStatus.lastPaidPeriod; period < currentPeriod; period ++ ) {
        periodAmount = repayments[period].amount * payeeStatus.share / repayments[period].payeesAmount;
        sum += periodAmount;
        repayments[period].paidOut += periodAmount;
        //TODO: check that period amount is positive?
      }
      payeeStatus.lastPaidPeriod = currentPeriod;
      payeeStatus.forWithdrawal = sum;

      // let's check if share changed
      periodAmount = getPayeeAmount(payee);
      if( periodAmount != payeeStatus.share ) {
        payeesAmount = payeesAmount - payeeStatus.share + periodAmount;
        payeeStatus.share = periodAmount;
      }
    }
  }

  function withdrawFee( address payee ) public {
    RegaFees.repaymentStatus storage payeeStatus = payees[payee];
    if( payeeStatus.forWithdrawal > 0 ) {
      uint256 sum = payeeStatus.forWithdrawal;
      payeeStatus.forWithdrawal = 0;
      payee.transfer(sum);
    }
  }

  function getPayeeAmount( address payee ) internal constant returns (uint256 balance) {
    return owner.balanceOf(payee);
  }
}
