pragma solidity ^0.4.0;

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 _amount, address _token, bytes _data) public;
}