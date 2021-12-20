// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./MAPBridgeV1.sol";

contract MAPBridgeRelayV1 is MAPBridgeV1 {
    uint mapChainId = 22776;

    function transferOutTokenBurn(address token, address to, uint amount, uint toChainId) external payable virtual override
    checkBalance(token,msg.sender,amount){
        IMAPToken(token).burn(msg.sender, amount);
        collectChainFee(toChainId);
        amount = getAmountWithdraw(amount);
        bytes32 orderId = getOrderID(token, msg.sender, to, amount, toChainId);
        emit mapTransferOut(token, msg.sender, to, orderId, amount, selfChainId, toChainId);
    }


    function transferOutToken(address token, address to, uint amount, uint toChainId) external payable virtual override
    checkBalance(token,msg.sender,amount){
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        collectChainFee(toChainId);
        amount = getAmountWithdraw(amount);
        bytes32 orderId = getOrderID(token, msg.sender, to, amount, toChainId);
        emit mapTransferOut(token, msg.sender, to, orderId, amount, selfChainId, toChainId);
    }


    function transferOutNative(address to, uint amount, uint toChainId) external payable virtual override
    checkNativeBalance(msg.sender,amount){
        require(msg.value >= amount, "value too low");
        IWToken(wToken).deposit{value : amount}();
        collectChainFee(toChainId);
        amount = getAmountWithdraw(amount);
        bytes32 orderId = getOrderID(address(0), msg.sender, to, amount, toChainId);
        emit mapTransferOut(address(0), msg.sender, to, orderId, amount, selfChainId, toChainId);
    }

    function transferInToken(address token, address from, address payable to, uint amount, bytes32 orderId, uint fromChain, uint toChain)
    external onlyOwner checkOrder(orderId) nonReentrant virtual override {
        amount = getAmountWithdraw(amount);
        if (toChain == mapChainId){
            IERC20(token).transfer(to, amount);
            emit mapTransferIn(token, from, to, orderId, amount, fromChain, toChain);
        }else{
            emit mapTransferOut(token, from, to, orderId, amount, fromChain, toChain);
        }
    }

    function transferInTokenMint(address token, address from, address payable to, uint amount, bytes32 orderId, uint fromChain, uint toChain)
    external onlyOwner checkOrder(orderId) nonReentrant virtual override {
        IMAPToken(token).mint(address(this), amount);
        amount = getAmountWithdraw(amount);
        if (toChain == mapChainId){
            IERC20(token).transfer(to,amount);
            emit mapTransferIn(token, from, to, orderId, amount, fromChain, toChain);
        }else{
            emit mapTransferOut(token, from, to, orderId, amount, fromChain, toChain);
        }
    }

    function transferInNative(address from, address payable to, uint amount, bytes32 orderId, uint fromChain, uint toChain)
    external onlyOwner checkOrder(orderId) nonReentrant virtual override {
        IWToken(wToken).withdraw(amount);
        amount = getAmountWithdraw(amount);
        if (toChain == mapChainId){
            to.transfer(amount);
            emit mapTransferIn(address(0), from, to, orderId, amount, fromChain, toChain);
        }else{
            emit mapTransferOut(address(0), from, to, orderId, amount, fromChain, toChain);
        }
    }

}