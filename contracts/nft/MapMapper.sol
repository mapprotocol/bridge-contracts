// SPDX-License-Identifier: MIT

pragma solidity >0.8.0;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract MAPERC721 is ERC721Enumerable, Ownable {
    string private basURI;


    mapping (uint256 => string) private _tokenURIs;

    constructor (string memory baseURI_, string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        _setBaseURI(baseURI_);
    }


    function _baseURI() internal view override returns (string memory) {
        return basURI;
    }


    function _setBaseURI(string memory baseURI_) internal {
        basURI = baseURI_;
    }

    function mint(address to, uint256 tokenId) external onlyOwner {
        _mint(to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) external onlyOwner {
        _setTokenURI(tokenId, _tokenURI);
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _setBaseURI(baseURI_);
    }

    function safeMint(address to, uint256 tokenId, bytes memory _data) external onlyOwner {
        _safeMint(to, tokenId, _data);
    }

    function multiMint(address[] memory tos, uint256[] memory tokenIds) external onlyOwner {
        require(tos.length == tokenIds.length, "illegal length");
        for (uint i = 0; i < tos.length; i ++) {
            _mint(tos[i], tokenIds[i]);
        }
    }

    function multiMintStart(address to, uint256 start, uint256 end) external onlyOwner {
        for (uint i = start; i <= end; i++) {
            _mint(to,i);
        }
    }

    function multiSafeMint(address[] memory tos, uint256[] memory tokenIds, bytes memory _data) external onlyOwner {
        require(tos.length == tokenIds.length, "illegal length");
        for (uint i = 0; i < tos.length; i ++) {
            _safeMint(tos[i], tokenIds[i], _data);
        }
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        string memory uri = super.tokenURI(tokenId);
        return string(abi.encodePacked(uri, ".json"));
    }
}