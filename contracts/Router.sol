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

    mapping(address => bool) mpc;
    uint256 public orderId;
    uint256 public chainID;
    mapping(uint256 => uint256) public chainOrder;
    
    
    ITxVerify txVerify;
    IRegister register;

    constructor(address verfiy, address registerAddress){
        mpc[msg.sender] = true;
        txVerify = ITxVerify(verfiy);
        register = IRegister(registerAddress);
        
        uint _chainId;
        assembly {
            _chainId := chainid()
        }
        chainID = _chainId;
    }


    modifier onlyMPC() {
        require(checkMpc(msg.sender), "FORBIDDEN");
        _;
    }

    function checkMpc(address _sender) view public returns (bool){
        return mpc[_sender];
    }


    function _swapIn(uint256 id, address token, address to, uint amount, uint fromChainID) internal {
        address mapToken = register.sourceCorrespond(fromChainID,token);
        require(mapToken != address(0),"token not register");
        IMapERC20(mapToken).mint(to, amount);
        emit LogSwapIn(id, token, address(0), to, amount, fromChainID, chainID);
    }

    // relayer submit tx to
    // @id nonce
    function swapIn(uint256 id, address token, address to, uint amount, uint fromChainID, address sourceRouter, bytes memory data) external {
        (bool check, string memory message) = txVerify.Verify(sourceRouter, token, fromChainID, chainID, data);
        if (!check) {
            emit LogSwapInFail(id, message, address(0), to, amount, fromChainID, chainID);
            return;
        }
        _swapIn(id, token, to, amount, fromChainID);
    }


    function _swapOut(address from, address token, address to, uint amount, uint toChainID) internal {
        orderId++;
        address sToken = register.sourceBinding(chainID,token);
        IMapERC20(sToken).transferFrom(from,address(this),amount);
        IMapERC20(token).mint(from, amount);
        IMapERC20(token).burn(from, amount);
        emit LogSwapOut(orderId, token, from, to, amount, chainID, toChainID);
    }

    // msg.sender deposit @amount @token to cross-chain transfer to @to at chain @toChainID
    function swapOut(address token, address to, uint amount, uint toChainID) external {
        _swapOut(msg.sender, token, to, amount, toChainID);
    }
}