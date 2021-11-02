pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interface/ITxVerify.sol";
import "./interface/IMapERC20.sol";
import "./interface/IRegister.sol";

contract Router {
    event LogSwapIn(bytes32 hash, address indexed token, address indexed from, address indexed to, uint amount, uint fromChainID, uint toChainID);
    event LogSwapOut(bytes32 hash, address indexed token, address indexed from, address indexed to, uint amount, uint fromChainID, uint toChainID);
    event LogSwapInFail(bytes32 hash, string message, address indexed from, address indexed to, uint amount, uint fromChainID, uint toChainID);

    uint public orderId;
    uint public chainID;

    mapping(bytes32 => bool) hashHandle;

    IRegister register;

    constructor(address registerAddress){
        register = IRegister(registerAddress);
        uint _chainId;
        assembly {
            _chainId := chainid()
        }
        chainID = _chainId;
    }


    modifier checkOrderHash(bytes32 hash){
        require(!hashHandle[hash],"order hash is have");
        _;
    }

    function setOrderHash(bytes32 hash) public {
        hashHandle[hash] = true;
    }

    function getTransactionID(uint nonce,address from, address token, address to, uint amount, uint toChainID) public view returns(bytes32){
        return keccak256(abi.encodePacked(nonce,from,token,to,amount,chainID,toChainID));
    }


    function _swapIn(bytes32 hash, address token, address to, uint amount, uint fromChainID) internal {
        address mapToken = register.sourceCorrespond(fromChainID, token);
        require(mapToken != address(0), "token not register");
        address sourceToken = register.sourceBinding(chainID,mapToken);
        require(sourceToken != address(0), "token not register");
        IMapERC20(mapToken).mint(to, amount);
        IMapERC20(mapToken).burn(to, amount);
        IERC20(sourceToken).transfer(to,amount);
        emit LogSwapIn(hash, token, address(0), to, amount, fromChainID, chainID);
    }

    function _swapBridge(bytes32 hash, address token, address to, uint amount, uint fromChainID, uint toChainID) internal {
        address mapToken = register.sourceCorrespond(fromChainID, token);
        require(mapToken != address(0), "token not register");
        IMapERC20(mapToken).mint(to, amount);
        IMapERC20(mapToken).burn(to, amount);
        emit LogSwapOut(hash, token, address(0), to, amount, chainID, toChainID);
    }

    function swapIn(bytes32 hash, address token, address to, uint amount, uint fromChainID,uint toChainID) external checkOrderHash(hash){
        if(toChainID == chainID){
            _swapIn(hash,token,to,amount,fromChainID);
        }else{
            _swapBridge(hash,token,to,amount,fromChainID,toChainID);
        }
        setOrderHash(hash);
    }


    function _swapOut(address from, address token, address to, uint amount, uint toChainID) internal {
        orderId++;
        bytes32 hash = getTransactionID(orderId,from,token,to,amount,toChainID);
        address sToken = register.sourceBinding(chainID, token);
        IMapERC20(sToken).transferFrom(from, address(this), amount);
        IMapERC20(token).mint(from, amount);
        IMapERC20(token).burn(from, amount);
        emit LogSwapOut(hash, token, from, to, amount, chainID, toChainID);
    }

    // msg.sender deposit @amount @token to cross-chain transfer to @to at chain @toChainID
    function swapOut(address token, address to, uint amount, uint toChainID) external {
        _swapOut(msg.sender, token, to, amount, toChainID);
    }
}