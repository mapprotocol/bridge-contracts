pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/ITxVerify.sol";
import "./interface/IMapERC20.sol";
import "./TokenRegister.sol";
import "./interface/IVote.sol";

contract Router is ReentrancyGuard, Ownable {

    event LogSwapIn(bytes32 hash, address indexed token, address indexed from, address indexed to, uint amount, uint fromChainID, uint toChainID);
    event LogSwapOut(bytes32 hash, address indexed token, address indexed from, address indexed to, uint amount, uint fromChainID, uint toChainID);
    event LogSwapInFail(bytes32 hash, string message, address indexed from, address indexed to, uint amount, uint fromChainID, uint toChainID);

    uint public nonce;
    uint public chainID;

    mapping(bytes32 => bool) hashHandle;

    TokenRegister tokenRegister;
    ITxVerify verify;
    IVote vote;

    constructor(TokenRegister _tokenRegister){
        tokenRegister = _tokenRegister;
        uint _chainId;
        assembly {_chainId := chainid()}
        chainID = _chainId;
    }

    modifier checkToken(uint fromChain, address source, uint toChain){
        require(address(0) != tokenRegister.getToToken(fromChain, source, toChain), "target token is empty");
        _;
    }


    modifier checkOrderHash(bytes32 hash){
        require(!hashHandle[hash], "order hash is have");
        _;
    }

    function setVerify(address _verify) public onlyOwner {
        verify = ITxVerify(_verify);
    }

    function setVote(address _vote) public onlyOwner {
        vote = IVote(_vote);
    }

    function setOrderHash(bytes32 hash) public {
        hashHandle[hash] = true;
    }

    function getNextTransactionID(address from, address token, address to, uint amount, uint toChainID) public returns (bytes32){
        nonce ++;
        return keccak256(abi.encodePacked(nonce, from, token, to, amount, chainID, toChainID));
    }


    function _swapIn(bytes32 hash, address token, address from, address to, uint amount, uint fromChainID) internal {
        _withdraw(token, amount, to);
        emit LogSwapIn(hash, token, from, to, amount, fromChainID, chainID);
    }

    function _swapBridge(bytes32 hash, address token, address from, address to, uint amount, uint toChainID) internal {
        emit LogSwapOut(hash, token, from, to, amount, chainID, toChainID);
    }


    function _withdraw(address _token, uint amount, address to) internal {
        IMapERC20 token = IMapERC20(_token);
        if (token.isMap()) {
            token.mint(to, amount);
        } else {
            token.transfer(to, amount);
        }
    }

    function swapIn(bytes32 hash, address token, address from, address to, uint amount, uint fromChainID, uint toChainID,
        address router, bytes memory txProve)
    external checkOrderHash(hash) nonReentrant() {
        if (txProve.length > 10) {
            require(verify.Verify(router, token, fromChainID, toChainID, txProve), "very fail");
        } else {
            require(vote.voteTx(hash), "vote fail");
        }
        if (toChainID == chainID) {
            _swapIn(hash, token, from, to, amount, fromChainID);
        } else {
            _swapBridge(hash, token, from, to, amount, toChainID);
        }
        setOrderHash(hash);
    }


    function _swapOut(address from, address token, address to, uint amount, uint toChainID) internal {
        address toToken = tokenRegister.getToToken(chainID, token, toChainID);
        require(toToken != address(0), "Other token is not Regisger");
        bytes32 hash = getNextTransactionID(from, token, to, amount, toChainID);
        _lock(token, amount);
        emit LogSwapOut(hash, toToken, from, to, amount, chainID, toChainID);
    }

    function _lock(address _token, uint amount) public {
        IMapERC20 token = IMapERC20(_token);
        if (token.isMap()) {
            token.burn(msg.sender, amount);
        } else {
            token.transferFrom(msg.sender, address(this), amount);
        }
    }

    // msg.sender deposit @amount @token to cross-chain transfer to @to at chain @toChainID
    function swapOut(address token, address to, uint amount, uint toChainID) external nonReentrant {
        _swapOut(msg.sender, token, to, amount, toChainID);
    }
}