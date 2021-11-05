pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenRegister {

    uint public mapChainID = 97;

    //chain => OtherToken => token
    mapping (uint => mapping(address => address)) public otherChainTokenToToken;
    //token => chain => OtherToken
    mapping (address => mapping(uint => address)) public tokenToOtherChainToken;


    function regToken(uint chain, address token, address otherToken) external {
        tokenToOtherChainToken[token][chain] = otherToken;
        otherChainTokenToToken[chain][otherToken] = token;
    }

    function getOtherToken(uint chain, address token) public view returns(address){
        return tokenToOtherChainToken[token][chain];
    }

    function getToken(uint chain, address otherToken)public view returns(address){
        return otherChainTokenToToken[chain][otherToken];
    }

    function getBirdgeToken(uint fromChain, address token,uint toChain)public view returns(address){
        return otherChainTokenToToken[toChain][tokenToOtherChainToken[token][fromChain]];
    }

    function getMapToken(address token) public view returns(address){
        return otherChainTokenToToken[mapChainID][token];
    }

    function getToToken(uint fromChian, address token,uint toChain)public view returns(address){
        if (toChain == mapChainID){
            return getMapToken(token);
        }
        return getBirdgeToken(fromChian,token,toChain);
    }
}
