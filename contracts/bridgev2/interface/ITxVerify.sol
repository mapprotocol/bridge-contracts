// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ITxVerify {
    function txVerify(address router, address coin, uint256 srcChain, uint256 destChain, bytes memory txProve) external view returns (bool success, string memory message);
}