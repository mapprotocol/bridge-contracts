pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED

contract CoinMapping{
    //Source chain to MAP chain
    mapping(uint256 => mapping(address => address)) sourceMapCoin;
    //MAP chain to target
    mapping(uint256 => mapping(address => address)) mapSourceCoin;

    function reg(uint256 sourceChain,uint256 sourceCoin,address mapCoin) public{
        sourceMapCoin[sourceChain] = sourceCoin[mapCoin];
        mapSourceCoin[sourceChain] = mapCoin[sourceCoin];
    }
}
