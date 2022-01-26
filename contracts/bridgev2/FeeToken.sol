// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interface/IFeeToken.sol";
import "../utils/Role.sol";


contract FeeCenter is IFeeToken, AccessControl, Initializable,Role {
    using SafeMath for uint;
    mapping(uint => address) public chainNativeToken;
    mapping(uint => mapping(address => uint)) public chainTokenGasFee;
    //must div 10000
    uint public transferFee;

    function setChainNativeToken(uint chain, address token) external onlyManager {
        chainNativeToken[chain] = token;
    }

    function setChainTokenGasFee(uint chain, address token, uint fee) external onlyManager {
        chainTokenGasFee[chain][token] = fee;
    }

    function setTransferFee(uint fee) external onlyManager {
        transferFee = fee;
    }

    function getTokenFee(address token, uint chain) external view override returns (uint fee){
        return chainTokenGasFee[chain][token];
    }

    function getTokenTransferFee(uint amount) external view override returns (uint fee){
        return amount.mul(transferFee).div(10000);
    }

    function getChainNativeToken(uint chain) external view override returns(address token){
        return chainNativeToken[chain];
    }

}