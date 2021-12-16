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
    uint nonce;

    IERC20 public mapToken;
    address public wToken;
    uint public transferPercentage;
    uint public selfChainId;

    mapping(bytes32 => address) public tokenRegister;
    //Gas transfer fee charged by the target chain
    mapping(uint => uint) public chainFee;
    mapping(bytes32 => bool) orderList;


    event logTransferOut(address indexed token, address indexed from, address indexed to, bytes32 orderId, uint amount, uint toChain);
    event logTransferIn(address indexed token, address indexed from, address indexed to, bytes32 orderId, uint amount, uint fromChain);
    event logTokenRegiser(bytes32 tokenID, address token);


    constructor(){
        uint _chainId;
        assembly {_chainId := chainid()}
        selfChainId = _chainId;
    }

    modifier checkOrder(bytes32 orderId){
        require(!orderList[orderId], "order is have");
        orderList[orderId] = true;
        _;
    }


    function getTokenId(address token) internal view returns (bytes32){
        return keccak256(abi.encodePacked(IERC20Metadata(token).name()));
    }

    function setOrder(bytes32 orderId) public {
        orderList[orderId] = true;
    }

    function getOrderID(address token, address from, address to, uint amount, uint toChainID) public returns (bytes32){
        return keccak256(abi.encodePacked(nonce++, from, token, to, amount, selfChainId, toChainID));
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


    function mapTransferOut(address token, address to, uint amount, uint toChainId) external payable {
        uint cFee = chainFee[toChainId];
        if (token == address(0)) {
            require(msg.value > 0, "value too low");
            IWToken(wToken).deposit{value : msg.value}();
        } else {
            IERC20(token).transferFrom(msg.sender, address(this), amount);
        }

        if (cFee > 0 && address(mapToken) == address(0)) {
            IWToken(wToken).deposit{value : cFee}();
        } else {
            mapToken.transferFrom(msg.sender, address(this), cFee);
        }
        bytes32 orderId = getOrderID(token,msg.sender,to,amount,toChainId);
        emit logTransferOut(token, msg.sender, to, orderId, amount, toChainId);
    }

    function mapTransferIn(address token, address from, address payable to, uint amount, bytes32 orderId, uint fromChain, uint toChain)
    external onlyOwner checkOrder(orderId) nonReentrant {
        uint amountOut = getAmountWithdraw(amount);
        if (toChain == selfChainId){
            if (token == address(0)) {
                IWToken(wToken).withdraw(amountOut);
                IERC20(wToken).transfer(msg.sender, amountOut);
            } else {
                IERC20(token).transfer(to, amountOut);
            }
            emit logTransferIn(token, from, to,orderId, amount, fromChain);
        }else{
            emit logTransferOut(token, from, to,orderId, amount, toChain);
        }

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
        wToken = token;
    }
}