// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interface/IFeeCenter.sol";
import "./utils/Role.sol";


contract FeeCenter is IFeeCenter, AccessControl, Initializable,Role {
    uint immutable chainId = block.chainid;
    using SafeMath for uint;
    mapping(uint => address) public chainNativeToken;
    mapping(uint => mapping (address => gasFee)) chainTokenGasFee;
    //token to vtoken
    mapping(address => address) tokenVault;


//    function

    function setChainNativeToken(uint chain, address token) external onlyManager {
        chainNativeToken[chain] = token;
    }

    function setChainTokenGasFee(uint to, address token, uint lowest, uint highest,uint proportion) external onlyManager {
        chainTokenGasFee[to][token] = gasFee(lowest,highest,proportion);
    }


    function getTokenFee(uint to, address token, uint amount) external view override returns (uint){
        gasFee memory gf =  chainTokenGasFee[to][token];
        uint fee = amount.mul(gf.proportion).div(10000);
        if (fee > gf.highest){
            return gf.highest;
        }else if (fee < gf.lowest){
            return gf.lowest;
        }
        return fee;
    }

    function getChainNativeToken(uint chain) external view override returns(address token){
        return chainNativeToken[chain];
    }

}