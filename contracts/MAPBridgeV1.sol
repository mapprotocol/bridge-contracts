// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract MAPBridgeV1 is ReentrancyGuard, Ownable {
    using SafeMath for uint;
    uint orderId;

    mapping(bytes32 => address) public tokenRegister;
    //Gas transfer fee charged by the target chain
    mapping(uint => uint) public chainFee;
    IERC20 public mapToken;
    uint public transferPercentage;
    mapping(uint => mapping(uint =>bool)) orderList;

    event logSwapOut(address token, address to, uint amount, uint toChain, uint orderId);
    event logWithdrawToken(address token, address to, uint amount, uint fromChain, uint orderId);
    event logTokenRegiser(bytes32 tokenID, address token);


    function setMapToken(address token) external onlyOwner {
        mapToken = IERC20(token);
    }

    function setChainFee(uint chainId, uint fee) external onlyOwner {
        chainFee[chainId] = fee;
    }

    function setTransferPercentage(uint fee) external onlyOwner {
        require(fee <= 10000, "Transfer percentage max 10000");
        transferPercentage = fee;
    }


    function getTokenId(address token) internal view returns (bytes32){
        return keccak256(abi.encodePacked(IERC20Metadata(token).name()));
    }

    function register(address token) public {
        bytes32 id = getTokenId(token);
        tokenRegister[id] = token;
        emit logTokenRegiser(id, token);
    }

    function swapOut(address token, address to, uint amount, uint toChain) external {
        uint cFee = chainFee[toChain];
        if (cFee > 0) {
            mapToken.transferFrom(msg.sender, address(this), cFee);
        }
        IERC20 lockToken = IERC20(token);
        lockToken.transferFrom(msg.sender, address(this), amount);
        emit logSwapOut(token, to, amount, toChain, orderId++);
    }

    function getAmountWithdraw(uint amount) public view returns (uint){
        if (transferPercentage == 0) {
            return amount;
        } else {
            return amount.mul(uint(10000).sub(transferPercentage)).div(10000);
        }
    }

    function setOrder(uint fromChain,uint oid) public{
        orderList[fromChain][oid] = true;
    }

    modifier checkOrder(uint fromChain,uint oid){
        require(!orderList[fromChain][oid],"order is have");
        _;
    }

    function withdrawToken(address token, address to,uint amount, uint fromChain, uint oid)
    external onlyOwner checkOrder(fromChain,oid) nonReentrant{
        setOrder(fromChain,oid);
        IERC20 lockToken = IERC20(token);
        uint amountOut = getAmountWithdraw(amount);
        lockToken.transfer(to, amountOut);
        emit logWithdrawToken(token, to,amount, fromChain, oid);
    }
}