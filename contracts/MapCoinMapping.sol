pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED

contract CoinMapping{
    //Source chain to MAP chain
    mapping(uint256 => mapping(address => address)) public sourceMapCoin;
    //MAP chain to target
    mapping(uint256 => mapping(address => address)) public mapSourceCoin;

    function reg(uint256 sourceChain,address sourceCoin, address mapCoin) external{
        sourceMapCoin[sourceChain][sourceCoin] = mapCoin;
        mapSourceCoin[sourceChain][mapCoin] = sourceCoin;
    }
}
