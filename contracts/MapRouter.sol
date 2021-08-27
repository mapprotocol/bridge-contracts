pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


interface MapERC20 is IERC20 {
    function mint(address to, uint256 amount) external returns (bool);
    function burn(address from, uint256 amount) external returns (bool);
}

interface SwapVerify{
    function txVerify(uint256 srcChain, uint256 destChain, bytes32[] memory txProve) external returns(bool, bytes32[] memory);
}

contract MapRouter {
    event LogSwapIn(uint orderId, address indexed token, address indexed from, address indexed to, uint amount, uint fromChainID, uint toChainID);
    event LogSwapOut(uint orderId, address indexed token, address indexed from, address indexed to, uint amount, uint fromChainID, uint toChainID);
    event LogSwapInFail(uint orderId, bytes32[] message,address indexed from, address indexed to, uint amount, uint fromChainID, uint toChainID);
    
    address _mpc;
    uint256 orderId;
    uint256 chainID;
    SwapVerify swapverify;
    mapping(uint256 => uint256) chainOrder;
    
    constructor(address mpcAddress, address verfiy){
        _mpc = mpcAddress;
        swapverify = SwapVerify(verfiy);
    }
    

    modifier onlyMPC() {
        require(msg.sender == mpc(), "FORBIDDEN");
        _;
    }

    function mpc()  view public returns(address){
        return _mpc;
    }


    function _swapIn(uint256 id, address token, address to, uint amount, uint fromChainID) internal {
        MapERC20(token).mint(to, amount);
        emit LogSwapIn(id, token, address(0),to, amount, fromChainID, chainID);
    }

    function swapIn(uint256 id, address token, address to, uint amount, uint fromChainID, bytes32[] memory data) external onlyMPC {
        (bool check,bytes32[] memory message) = swapverify.txVerify(fromChainID,chainID,data);
        if (!check){
            emit LogSwapInFail(id, message, address(0),to, amount, fromChainID, chainID);
            return;
        }
        _swapIn(id, token, to, amount, fromChainID);
    }


    function _swapOut(address from, address token, address to, uint amount, uint toChainID) internal {
        orderId++;
        MapERC20(token).burn(from, amount);
        emit LogSwapOut(orderId,token, from, to, amount, chainID, toChainID);
    }

    function swapOut(address token, address to, uint amount, uint toChainID) external {
        _swapOut(msg.sender, token, to, amount, toChainID);
    }
}