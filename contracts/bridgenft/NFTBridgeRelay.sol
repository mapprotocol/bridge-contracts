// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './NFTToken.sol';
import '../interface/IFeeCenter.sol';
import '../utils/Role.sol';
import '../interface/IMAPToken.sol';

contract NFTBridgeRelay is Ownable, Role{
    uint immutable chainId = block.chainid;
    uint nonce;
    IFeeCenter feeCenter;
    mapping(address => mapping(uint => address)) public wrappedAssets;


    event mapTransferInNFT(bytes32 indexed orderId,address  indexed token, uint tokenID, uint fromChain, uint toChain, uint nativeChain);
    event mapTransferOutNFT(bytes32 indexed orderId,address indexed token, uint tokenID, uint fromChain, uint toChain, uint nativeChain);

    function getOrderID(address token, address from, address to, uint toChainID) public returns (bytes32){
        return keccak256(abi.encodePacked(nonce++, from, to, token, chainId, toChainID));
    }

    function setFeeCenter(address fee) external onlyManager{
        feeCenter = IFeeCenter(fee);
    }

    function transferOutNFT(address _token, address to, uint tokenID, uint toChain) public {
        NFTToken token = NFTToken(_token);

        bytes32 orderId = getOrderID(_token,msg.sender,to,toChain);

        if (token.nativeContract() != address(0)) {
            token.lock(msg.sender, tokenID);
            emit mapTransferInNFT(orderId,token.nativeContract(), tokenID, chainId, toChain, token.nativeChain());
        } else {
            IERC721(token).transferFrom(msg.sender, address(this), tokenID);
            emit mapTransferInNFT(orderId,_token, tokenID, chainId, toChain, token.nativeChain());
        }
    }

    function _mintFee(uint fromChain,uint toChain) internal {
        address fromNative = feeCenter.getChainNativeToken(fromChain);
        uint fee = feeCenter.getTokenFee(fromNative,toChain);
        IMAPToken(fromNative).mint(address(this),fee);
    }

    function transferInNFT(address _token, address to, uint tokenID, uint fromChain, uint toChain, uint nativeChain,
        string memory name, string memory symbol, string memory tokenURI) public onlyOwner {
        NFTToken token = NFTToken(_token);

        _mintFee(fromChain,toChain);

        bytes32 orderId = getOrderID(_token,msg.sender,to,chainId);

        if (chainId == nativeChain) {
            IERC721(token).transferFrom(address(this), to, tokenID);
            emit mapTransferInNFT(orderId,_token, tokenID, fromChain, chainId, nativeChain);
        } else {
            address localWrapped = wrappedAssets[_token][fromChain];
            if (localWrapped == address(0)) {
                token = new NFTToken(name, symbol, _token, fromChain);
                wrappedAssets[_token][fromChain] = address(token);
            } else {
                token = NFTToken(localWrapped);
            }
            token.mint(to, tokenID);
            token.setTokenURI(tokenID, tokenURI);
            emit mapTransferOutNFT(orderId,_token, tokenID, fromChain, chainId, token.nativeChain());
        }
    }
}