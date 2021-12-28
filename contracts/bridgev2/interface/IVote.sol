// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IVote {
    function voteTx(bytes32 hash,address voter) external view returns(bool);
}