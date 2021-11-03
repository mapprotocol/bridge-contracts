// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MapERC20 is ERC20 {
    uint8 immutable private DECIMALS;

    address public router;

    modifier onlyRouter() {
        require(msg.sender == router, "forbidden");
        _;
    }

    function getMapString(string memory str) public pure returns(string memory mapStr){
        return string(abi.encodePacked("MAP",str));
    }

    function getErc20Name(address token) public view returns(string memory){
        return getMapString(IERC20Metadata(token).name());
    }

    function getErc20Symbol(address token) public view returns(string memory){
        return getMapString(IERC20Metadata(token).symbol());
    }

    constructor(address token, address _router) ERC20(getErc20Name(token),getErc20Symbol(token)) {
        DECIMALS = IERC20Metadata(token).decimals();
        router = _router;
    }

    function decimals() public view override returns (uint8) {
        return DECIMALS;
    }

    function mint(address to, uint256 amount) external onlyRouter {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyRouter{
        _burn(from, amount);
    }
}