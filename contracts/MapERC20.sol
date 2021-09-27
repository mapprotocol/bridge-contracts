// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract MapERC20 is ERC20Burnable {
    uint8 immutable private DECIMALS;

    address public router;

    modifier onlyRouter() {
        require(msg.sender == router, "forbidden");
        _;
    }

    constructor(
        address token, string memory _name, string memory _symbol, address _router
    ) ERC20(_name, _symbol) {
        DECIMALS = IERC20Metadata(token).decimals();
        router = _router;
    }

    function decimals() public view override returns (uint8) {
        return DECIMALS;
    }

    function mint(address to, uint256 amount) external onlyRouter {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyRouter {
        burnFrom(from, amount);
    }
}