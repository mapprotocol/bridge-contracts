// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IFeeCenter {
    function getTokenFee(address token, uint chain) external view returns (uint fee);
    function getTokenTransferFee(uint amount) external view returns (uint fee);
    function getChainNativeToken(uint chain) external view returns(address token);
}