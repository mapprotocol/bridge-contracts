// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../MAPBridgeV1.sol";

contract MAPBridgeRelayV1 is MAPBridgeV1 {
    using SafeMath for uint;
    uint public transferFee;    // tranfer fee for every token, one in a million
    mapping (address => uint) public transferFeeList;


    function setTransferFee(uint fee) external onlyManager {
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

    function collectChainFee(uint toChainId,uint native) internal{
        uint cFee = chainGasFee[toChainId];
        if (cFee > 0) {
            require(msg.value >= cFee.add(native),"balance too low");
        }
    }

    function transferOutTokenBurn(address token, address to, uint amount, uint toChainId) external virtual override
    checkBalance(token,msg.sender,amount)  {
        //IERC20(token).transferFrom(msg.sender, address(this), amount);
        TransferHelper.safeTransferFrom(token,msg.sender,address(this),amount);
        collectChainFee(toChainId,0);
        uint outAmount = getAmountWithdraw(amount);
        transferFeeList[token] = transferFeeList[token].add(amount).sub(outAmount);
        IMAPToken(token).burn(outAmount);
        bytes32 orderId = getOrderID(token, msg.sender, to, outAmount, toChainId);
        emit mapTransferOut(token, msg.sender, to, orderId, outAmount, selfChainId, toChainId);
    }


    function transferOutToken(address token, address to, uint amount, uint toChainId) external virtual override
    checkBalance(token,msg.sender,amount)  {
        //IERC20(token).transferFrom(msg.sender, address(this), amount);
        TransferHelper.safeTransferFrom(token,msg.sender,address(this),amount);
        collectChainFee(toChainId,0);
        uint outAmount = getAmountWithdraw(amount);
        transferFeeList[token] = transferFeeList[token].add(amount).sub(outAmount);
        bytes32 orderId = getOrderID(token, msg.sender, to, outAmount, toChainId);
        emit mapTransferOut(token, msg.sender, to, orderId, outAmount, selfChainId, toChainId);
    }

    function transferOutNative(address to, uint amount, uint toChainId) external payable virtual override {
        IWToken(wToken).deposit{value : amount}();
        collectChainFee(toChainId,amount);
        uint outAmount = getAmountWithdraw(amount);
        transferFeeList[address(0)] = transferFeeList[address(0)].add(amount).sub(outAmount);
        bytes32 orderId = getOrderID(address(0), msg.sender, to, outAmount, toChainId);
        emit mapTransferOut(address(0), msg.sender, to, orderId, outAmount, selfChainId, toChainId);
    }


    function transferInToken(address token, address from, address payable to, uint amount, bytes32 orderId, uint fromChain, uint toChain)
    external checkOrder(orderId) nonReentrant virtual override onlyManager{
        uint outAmount = getAmountWithdraw(amount);
        if (toChain == selfChainId) {
            require(IERC20(token).balanceOf(address(this)) >= amount,"balance too low");
//            IERC20(token).transfer(to, outAmount);
            TransferHelper.safeTransfer(token,to,amount);
            emit mapTransferIn(token, from, to, orderId, outAmount, fromChain, toChain);
        }else{
            emit mapTransferOut(token, from, to, orderId, outAmount, fromChain, toChain);
        }
    }

    function transferInTokenMint(address token, address from, address payable to, uint amount, bytes32 orderId, uint fromChain, uint toChain)
    external checkOrder(orderId) nonReentrant virtual override onlyManager{
        IMAPToken(token).mint(address(this), amount);
        uint outAmount = getAmountWithdraw(amount);
        if (toChain == selfChainId){
//            IERC20(token).transfer(to, outAmount);
            TransferHelper.safeTransfer(token,to,amount);
            emit mapTransferIn(token, from, to, orderId, outAmount, fromChain, toChain);
        }else{
            IMAPToken(token).burn(outAmount);
            emit mapTransferOut(token, from, to, orderId, outAmount, fromChain, toChain);
        }
    }

    function transferInNative(address from, address payable to, uint amount, bytes32 orderId, uint fromChain, uint toChain)
    external checkOrder(orderId) nonReentrant virtual override onlyManager{
        uint outAmount = getAmountWithdraw(amount);
        if (toChain == selfChainId){
            require(IERC20(wToken).balanceOf(address(this)) >= amount,"balance too low");
//            IWToken(wToken).withdraw(outAmount);
//            to.transfer(outAmount);
            TransferHelper.safeWithdraw(wToken,amount);
            TransferHelper.safeTransferETH(to,amount);
            emit mapTransferIn(address(0), from, to, orderId, outAmount, fromChain, toChain);
        }else{
            emit mapTransferOut(address(0), from, to, orderId, outAmount, fromChain, toChain);
        }
    }

    //constructor(){
        //initialize(0x3CDF7A63f514092b42FFA697aC01D81d37A2F34d,0x0000000000000000000000000000000000000000);
    //}
}