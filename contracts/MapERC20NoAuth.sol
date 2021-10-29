// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract MapERC20NoAuth is  ERC20Burnable {
    uint8 immutable private DECIMALS;

    constructor(address token, string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        DECIMALS = IERC20Metadata(token).decimals();
    }

    function decimals() public view override returns (uint8) {
        return DECIMALS;
    }

    function mint(address to, uint256 amount) external  {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        burnFrom(from, amount);
    }
}