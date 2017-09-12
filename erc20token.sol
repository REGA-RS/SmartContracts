pragma solidity ^0.4.10;

import './interfaces/ierc20token.sol';
import './regautils.sol';

/**
    ERC20 Standard Token implementation
*/
contract ERC20Token is IERC20Token, RegaUtils {
  uint256 public totalSupply = 0;
  mapping( address => uint256 ) public balanceOf;
  mapping( address => mapping( address => uint256 ) ) public allowance;

  event Transfer( address indexed _from, address indexed _to, uint256 _value );
  event Approval( address indexed _owner, address indexed _spender, uint256 _value );

  function transfer( address _to, uint256 _value ) validAddress( _to )
    returns( bool success )
  {
    balanceOf[ msg.sender ] = safeSub( balanceOf[ msg.sender ], _value );
    balanceOf[ _to ] = safeAdd( balanceOf[ _to ], _value );
    Transfer( msg.sender, _to, _value );
    return true;
  }

  function transferFrom( address _from, address _to, uint256 _value ) validAddress( _from ) validAddress( _to )
    returns( bool success )
  {
    allowance[ _from ][ msg.sender ] = safeSub( allowance[ _from ][ msg.sender ], _value );
    balanceOf[ _from] = safeSub( balanceOf[_from], _value );
    balanceOf[ _to] = safeAdd( balanceOf[_to], _value );
    Transfer( _from, _to, _value );
    return true;
  }

  function approve( address _spender, uint256 _value ) validAddress( _spender )
    returns( bool success)
  {
    require( _value == 0 || allowance[ msg.sender ][ _spender ] == 0 );

    allowance[ msg.sender ][ _spender ] = _value;
    Approval( msg.sender, _spender, _value );
    return true;
  }

}