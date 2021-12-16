// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IWToken {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}


contract MAPBridgeV1 is ReentrancyGuard, Ownable {
    using SafeMath for uint;
    uint orderId;

    IERC20 public mapToken;
    address public wToken;
    uint public transferPercentage;

    mapping(bytes32 => address) public tokenRegister;
    //Gas transfer fee charged by the target chain
    mapping(uint => uint) public chainFee;
    mapping(uint => mapping(uint => bool)) orderList;


    event logTransferOut(address token, address from, address to, uint amount, uint toChain, uint orderId);
    event logTransferIn(address token, address from, address to, uint amount, uint fromChain, uint orderId);
    event logTokenRegiser(bytes32 tokenID, address token);


    function getTokenId(address token) internal view returns (bytes32){
        return keccak256(abi.encodePacked(IERC20Metadata(token).name()));
    }

    function setOrder(uint fromChain, uint oid) public {
        orderList[fromChain][oid] = true;
    }

    modifier checkOrder(uint fromChain, uint oid){
        require(!orderList[fromChain][oid], "order is have");
        _;
    }

    function register(address token) public {
        bytes32 id = getTokenId(token);
        tokenRegister[id] = token;
        emit logTokenRegiser(id, token);
    }

    function getAmountWithdraw(uint amount) public view returns (uint){
        if (transferPercentage == 0) {
            return amount;
        } else {
            return amount.mul(uint(10000).sub(transferPercentage)).div(10000);
        }
    }


    function mapTransferOut(address token, address to, uint amount, uint toChain) external payable{
        uint cFee = chainFee[toChain];
        if (token == address(0)){
            require(msg.value > 0,"value too low");
            IWToken(wToken).deposit{value: msg.value}();
        }else{
            IERC20(token).transferFrom(msg.sender, address(this), amount);
        }

        if (cFee > 0 && address(mapToken) == address(0)) {
            IWToken(wToken).deposit{value:cFee}();
        }else{
            mapToken.transferFrom(msg.sender, address(this), cFee);
        }

        emit logTransferOut(token, msg.sender, to, amount, toChain, orderId++);
    }

    function mapTransferIn(address token, address from, address payable to, uint amount, uint fromChain, uint oid)
    external onlyOwner checkOrder(fromChain, oid) nonReentrant {
        setOrder(fromChain, oid);
        uint amountOut = getAmountWithdraw(amount);
        if(token == address(0)){
            IWToken(wToken).withdraw(amountOut);
            IERC20(wToken).transfer(msg.sender, amountOut);
        }else{
            IERC20(token).transfer(to, amountOut);
        }
        emit logTransferIn(token, from, to, amount, fromChain, oid);
    }


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

    function setWToken(address token) external onlyOwner {
        wToken =token;
    }
}