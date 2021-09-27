pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED

contract TokenRegister {
    //Source chain to MAP chain
    mapping(uint256 => mapping(address => address)) public sourceCorrespond;
    //MAP chain to target
    mapping(uint256 => mapping(address => address)) public mapCorrespond;
    //Source token binding
    mapping(uint256 => mapping(address => address)) public sourceBinding;

    function regToken(
        uint256 sourceChain, address sourceToken, address sourceMapToken, address mapToken
    ) external {
        sourceCorrespond[sourceChain][sourceMapToken] = mapToken;
        mapCorrespond[sourceChain][mapToken] = sourceMapToken;
        sourceBinding[sourceChain][sourceMapToken] = sourceToken;
    }

    function getTargetToken(
        uint256 sourceChain, address sourceToken, uint256 targetChain
    ) external view returns (address mapToken){
        return mapCorrespond[targetChain][sourceCorrespond[sourceChain][sourceToken]];
    }
}
