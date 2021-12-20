// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./MAPBridgeV1.sol";

contract MAPBridgeRelayV1 is MAPBridgeV1 {
    uint public transferFee;    // tranfer fee for every token, one in a million

    function setTransferFee(uint fee) external onlyOwner {
        require(fee <= 1000000, "Transfer fee percentage max 1000000");
        transferFee = fee;
    }

    function getAmountWithdraw(uint amount) public view returns (uint){
        if (transferFee == 0) {
            return amount;
        } else {
            return amount.mul(uint(1000000).sub(transferFee)).div(1000000);
        }
    }

    function transferOutTokenBurn(address token, address to, uint amount, uint toChainId) external payable virtual override
    checkBalance(token,msg.sender,amount){
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        collectChainFee(toChainId);
        outAmount = getAmountWithdraw(amount);
        IMAPToken(token).burn(address(this), outAmount);
        bytes32 orderId = getOrderID(token, msg.sender, to, outAmount, toChainId);
        emit mapTransferOut(token, msg.sender, to, orderId, outAmount, selfChainId, toChainId);
    }


    function transferOutToken(address token, address to, uint amount, uint toChainId) external payable virtual override
    checkBalance(token,msg.sender,amount){
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        collectChainFee(toChainId);
        outAmount = getAmountWithdraw(amount);
        bytes32 orderId = getOrderID(token, msg.sender, to, outAmount, toChainId);
        emit mapTransferOut(token, msg.sender, to, orderId, outAmount, selfChainId, toChainId);
    }

    function transferOutNative(address to, uint amount, uint toChainId) external payable virtual override
    checkNativeBalance(msg.sender,amount){
        IWToken(wToken).deposit{value : amount}();
        collectChainFee(toChainId);
        outAmount = getAmountWithdraw(amount);
        bytes32 orderId = getOrderID(address(0), msg.sender, to, outAmount, toChainId);
        emit mapTransferOut(address(0), msg.sender, to, orderId, outAmount, selfChainId, toChainId);
    }

    function transferInToken(address token, address from, address payable to, uint amount, bytes32 orderId, uint fromChain, uint toChain)
    external onlyOwner checkOrder(orderId) nonReentrant virtual override {
        outAmount = getAmountWithdraw(amount);
        if (toChain == selfChainId) {
            checkBalance(token, address(this), outAmount);
            IERC20(token).transfer(to, outAmount);
            emit mapTransferIn(token, from, to, orderId, outAmount, fromChain, toChain);
        }else{
            emit mapTransferOut(token, from, to, orderId, outAmount, fromChain, toChain);
        }
    }

    function transferInTokenMint(address token, address from, address payable to, uint amount, bytes32 orderId, uint fromChain, uint toChain)
    external onlyOwner checkOrder(orderId) nonReentrant virtual override {
        IMAPToken(token).mint(address(this), amount);
        outAmount = getAmountWithdraw(amount);
        if (toChain == selfChainId){
            IERC20(token).transfer(to, outAmount);
            emit mapTransferIn(token, from, to, orderId, outAmount, fromChain, toChain);
        }else{
            IMAPToken(token).burn(address(this), outAmount);
            emit mapTransferOut(token, from, to, orderId, outAmount, fromChain, toChain);
        }
    }

    function transferInNative(address from, address payable to, uint amount, bytes32 orderId, uint fromChain, uint toChain)
    external onlyOwner checkOrder(orderId) nonReentrant virtual override {
        outAmount = getAmountWithdraw(amount);
        if (toChain == selfChainId){
            checkBalance(IWToken(wToken), address(this), outAmount);
            IWToken(wToken).withdraw(outAmount);
            to.transfer(outAmount);
            emit mapTransferIn(address(0), from, to, orderId, outAmount, fromChain, toChain);
        }else{
            emit mapTransferOut(address(0), from, to, orderId, outAmount, fromChain, toChain);
        }
    }

}