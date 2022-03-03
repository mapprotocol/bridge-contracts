// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IFeeCenter {
    struct gasFee{
        uint lowest;
        uint highest;
        //must div 10000
        uint proportion;
    }

    function getTokenFee(uint to, address token, uint amount) external view returns (uint fee);
    function getVaultToken(address token) external view returns(address vault);
    function doDistribute(address token,uint amount) external;
}