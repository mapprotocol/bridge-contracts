// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token2 is ERC20 {
    bool public isMap = true;
    constructor(address to) ERC20("Test Coin", "TC") {
        _mint(to,100000000000000000000000000);
    }

    function mint(address to, uint256 amount) external  {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}