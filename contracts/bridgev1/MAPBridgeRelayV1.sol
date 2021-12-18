// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./MAPBridgeV1.sol";

contract MAPBridgeRelayV1 is MAPBridgeV1 {
    function transferInToken(address token, address from, address payable to, uint amount, bytes32 orderId, uint fromChain)
    external onlyOwner checkOrder(orderId) nonReentrant virtual override {
        amount = getAmountWithdraw(amount);
        IERC20(token).transfer(to, amount);
        emit mapTransferIn(token, from, to, orderId, amount, fromChain, selfChainId);
    }

    function transferInTokenMint(address token, address from, address payable to, uint amount, bytes32 orderId, uint fromChain)
    external onlyOwner checkOrder(orderId) nonReentrant virtual override {
        amount = getAmountWithdraw(amount);
        IMAPToken(token).mint(to, amount);
        emit mapTransferIn(token, from, to, orderId, amount, fromChain, selfChainId);
    }

    function transferInStandard(address from, address payable to, uint amount, bytes32 orderId, uint fromChain)
    external onlyOwner checkOrder(orderId) nonReentrant virtual override {
        amount = getAmountWithdraw(amount);
        IWToken(wToken).withdraw(amount);
        to.transfer(amount);
        emit mapTransferIn(address(0), from, to, orderId, amount, fromChain, selfChainId);
    }

    function transferInBirdge(address from, address payable to, uint amount, bytes32 orderId, uint tochain)
    external onlyOwner checkOrder(orderId) nonReentrant {
        amount = getAmountWithdraw(amount);
        emit mapTransferOut(address(0), from, to, orderId, amount, selfChainId, tochain);
    }
}