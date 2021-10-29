pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interface/ITxVerify.sol";
import "./interface/IMapERC20.sol";
import "./interface/IRegister.sol";

contract Router {
    event LogSwapIn(uint orderId, address indexed token, address indexed from, address indexed to, uint amount, uint fromChainID, uint toChainID);
    event LogSwapOut(uint orderId, address indexed token, address indexed from, address indexed to, uint amount, uint fromChainID, uint toChainID);
    event LogSwapInFail(uint orderId, string message, address indexed from, address indexed to, uint amount, uint fromChainID, uint toChainID);

    uint public orderId;
    uint public chainID;
    mapping(uint => mapping(uint => bool)) public chainOrder;

    IRegister register;

    constructor(address registerAddress){
        register = IRegister(registerAddress);

        uint _chainId;
        assembly {
            _chainId := chainid()
        }
        chainID = _chainId;
    }


    modifier checkOrderId(uint chain,uint oid){
        require(chainOrder[chain][oid],"order is have");
        _;
    }

    function setChainOrder(uint chain,uint oid) public {
        chainOrder[chain][oid] = true;
    }

    function _swapIn(uint id, address token, address to, uint amount, uint fromChainID) internal {
        address mapToken = register.sourceCorrespond(fromChainID, token);
        require(mapToken != address(0), "token not register");
        address sourceToken = register.mapCorrespond(fromChainID,mapToken);
        require(sourceToken != address(0), "token not register");
        IMapERC20(mapToken).mint(to, amount);
        IMapERC20(mapToken).burn(to, amount);
        IERC20(sourceToken).transfer(to,amount);
        emit LogSwapIn(id, token, address(0), to, amount, fromChainID, chainID);
    }

    function _swapBridge(uint id, address token, address to, uint amount, uint fromChainID, uint toChainID) internal {
        address mapToken = register.sourceCorrespond(fromChainID, token);
        require(mapToken != address(0), "token not register");
        IMapERC20(mapToken).mint(to, amount);
        IMapERC20(mapToken).burn(to, amount);
        emit LogSwapOut(id, token, address(0), to, amount, chainID, toChainID);
    }

    function swapIn(uint id, address token, address to, uint amount, uint fromChainID,uint toChainID) external {
        if(toChainID == chainID){
            _swapIn(id,token,to,amount,fromChainID);
        }else{
            _swapBridge(id,token,to,amount,fromChainID,toChainID);
        }
    }


    function _swapOut(address from, address token, address to, uint amount, uint toChainID) internal {
        orderId++;
        address sToken = register.sourceBinding(chainID, token);
        IMapERC20(sToken).transferFrom(from, address(this), amount);
        IMapERC20(token).mint(from, amount);
        IMapERC20(token).burn(from, amount);
        emit LogSwapOut(orderId, token, from, to, amount, chainID, toChainID);
    }

    // msg.sender deposit @amount @token to cross-chain transfer to @to at chain @toChainID
    function swapOut(address token, address to, uint amount, uint toChainID) external {
        _swapOut(msg.sender, token, to, amount, toChainID);
    }
}