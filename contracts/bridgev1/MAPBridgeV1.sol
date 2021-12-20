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


interface IMAPToken {
    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;
}


contract MAPBridgeV1 is ReentrancyGuard, Ownable {
    using SafeMath for uint;
    uint public nonce;

    IERC20 public mapToken;
    address public wToken;          // native wrapped token

    uint public selfChainId;

    mapping(bytes32 => address) public tokenRegister;
    //Gas transfer fee charged by the target chain
    mapping(uint => uint) public chainGasFee;
    mapping(bytes32 => bool) orderList;

    event mapTransferOut(address indexed token, address indexed from, address indexed to,
        bytes32 orderId, uint amount, uint fromChain, uint toChain);
    event mapTransferIn(address indexed token, address indexed from, address indexed to,
        bytes32 orderId, uint amount, uint fromChain, uint toChain);
    event mapTokenRegister(bytes32 tokenID, address token);


    constructor(){
        uint _chainId;
        assembly {_chainId := chainid()}
        selfChainId = _chainId;
    }


    modifier checkOrder(bytes32 orderId) {
        require(!orderList[orderId], "order exist");
        orderList[orderId] = true;
        _;
    }

    modifier checkBalance(address token, address sender,uint amount){
        require(IERC20(token).balanceOf(sender) >= amount,"balance too low");
        _;
    }

    modifier checkNativeBalance(address sender,uint amount){
        require(payable(sender).balance >= amount,"native balance too low");
        _;
    }

    function getTokenId(address token) internal view returns (bytes32){
        return keccak256(abi.encodePacked(IERC20Metadata(token).name()));
    }

    function getTokenIdForName(string memory name) internal pure returns (bytes32){
        return keccak256(abi.encodePacked(name));
    }

    function getOrderID(address token, address from, address to, uint amount, uint toChainID) public returns (bytes32){
        return keccak256(abi.encodePacked(nonce++, from, to, token, amount, selfChainId, toChainID));
    }

    function register(address token, string memory name) public {
        bytes32 id;
        if (bytes(name).length > 0) {
            id = getTokenIdForName(name);
        } else {
            id = getTokenId(token);
        }
        tokenRegister[id] = token;
        emit mapTokenRegister(id, token);
    }

    function collectChainFee(uint toChainId) public{
        uint cFee = chainGasFee[toChainId];
        if (cFee > 0) {
            require(mapToken.balanceOf(msg.sender) >= cFee,"balance too low");
            mapToken.transferFrom(msg.sender, address(this), cFee);
        }
    }

    function transferOutTokenBurn(address token, address to, uint amount, uint toChainId) external virtual
    checkBalance(token,msg.sender,amount){
        IMAPToken(token).burn(msg.sender, amount);
        collectChainFee(toChainId);
        bytes32 orderId = getOrderID(token, msg.sender, to, amount, toChainId);
        emit mapTransferOut(token, msg.sender, to, orderId, amount, selfChainId, toChainId);
    }


    function transferOutToken(address token, address to, uint amount, uint toChainId) external virtual
    checkBalance(token,msg.sender,amount){
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        collectChainFee(toChainId);
        bytes32 orderId = getOrderID(token, msg.sender, to, amount, toChainId);
        emit mapTransferOut(token, msg.sender, to, orderId, amount, selfChainId, toChainId);
    }


    function transferOutNative(address to, uint amount, uint toChainId) external payable virtual
    checkNativeBalance(msg.sender,amount){
        require(msg.value >= amount, "value too low");
        IWToken(wToken).deposit{value : amount}();
        collectChainFee(toChainId);
        bytes32 orderId = getOrderID(address(0), msg.sender, to, amount, toChainId);
        emit mapTransferOut(address(0), msg.sender, to, orderId, amount, selfChainId, toChainId);
    }


    function transferInToken(address token, address from, address payable to, uint amount, bytes32 orderId, uint fromChain, uint toChain)
    external onlyOwner checkOrder(orderId) checkBalance(token, address(this), amount) nonReentrant virtual {
        IERC20(token).transfer(to, amount);
        emit mapTransferIn(token, from, to, orderId, amount, fromChain, toChain);
    }

    function transferInTokenMint(address token, address from, address payable to, uint amount, bytes32 orderId, uint fromChain, uint toChain)
    external onlyOwner checkOrder(orderId) nonReentrant virtual {
        IMAPToken(token).mint(to, amount);
        emit mapTransferIn(token, from, to, orderId, amount, fromChain, toChain);
    }

    function transferInNative(address from, address payable to, uint amount, bytes32 orderId, uint fromChain, uint toChain)
    external onlyOwner checkOrder(orderId) checkBalance(wToken, address(this), amount) nonReentrant virtual {
        IWToken(wToken).withdraw(amount);
        to.transfer(amount);
        emit mapTransferIn(address(0), from, to, orderId, amount, fromChain, toChain);
    }

    function setMapToken(address token) external onlyOwner {
        mapToken = IERC20(token);
    }

    function setChainFee(uint chainId, uint fee) external onlyOwner {
        chainGasFee[chainId] = fee;
    }

    function setWToken(address token) external onlyOwner {
        wToken = token;
    }
}