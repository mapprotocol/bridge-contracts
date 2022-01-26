// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract CashBox{
    uint accrualBlockNumber;
    address mainCoin = address (0);
    mapping(address => uint) tokenStakingAmount;
    mapping(address => mapping(address => uint)) tokenUserStakingAmount;

    function getTokenAllStaking(address token) internal view returns(uint){
        return tokenStakingAmount[token];
    }


//    function mining()


}