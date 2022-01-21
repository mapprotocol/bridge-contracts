// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interface/IFeeCenter.sol";


contract FeeCenter is IFeeCenter, AccessControl, Initializable {
    using SafeMath for uint;
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    mapping(uint => address) public chainNativeToken;
    mapping(uint => mapping(address => uint)) public chainTokenGasFee;
    //must div 10000
    uint public transferFee;

    function initialize() public initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
    }

    function setChainNativeToken(uint chain, address token) external onlyRole(MANAGER_ROLE) {
        chainNativeToken[chain] = token;
    }

    function setChainTokenGasFee(uint chain, address token, uint fee) external onlyRole(MANAGER_ROLE) {
        chainTokenGasFee[chain][token] = fee;
    }

    function setTransferFee(uint fee) external onlyRole(MANAGER_ROLE) {
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