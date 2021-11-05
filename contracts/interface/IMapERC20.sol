pragma solidity ^0.8.0;
// SPDX-License-Identifier: UNLICENSED
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IMapERC20 is IERC20 {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
    function isMap() external view returns(bool) ;
}