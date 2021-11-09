pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED

interface IVote {
    function voteTx(bytes32 hash) external view returns(bool);
}