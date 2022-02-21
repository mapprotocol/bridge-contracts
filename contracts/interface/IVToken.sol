// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IVToken {
    function stakingTo(uint amount, address to) external;
}