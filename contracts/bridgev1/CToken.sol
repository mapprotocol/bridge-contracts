// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


//contract CToken is ERC20,Initializable{
//    using SafeMath for uint;
//    uint accrualBlockNumber;
//    address mainCoin = address (0);
//    mapping(address => uint) UserStakingAmount;
//
//    address correspond;
//    IERC20 correspondToken;
//    uint8 _decimals;
//
//
//    function initialize(
//        address correspond_,
//        string memory name_,
//        string memory symbol_,
//        uint8 decimals_,
//        address erc20) external ERC20(name_,symbol_){
//        correspond = correspond_;
//        correspondToken = IERC20(correspond);
//        _decimals = decimals_;
//    }
//
//    function decimals() public view virtual override returns (uint8) {
//        return _decimals;
//    }
//
//
//    function correspondBalance() public view returns(uint){
//        return IERC20(correspond).balanceOf(address(this));
//    }
//
//    function getCTokenQuantity(uint amount) public view returns(uint){
//        uint allCorrespond = correspondBalance();
//        uint allCToken = totalSupply();
//        return amount.mul(allCToken).div(allCorrespond);
//    }
//
//    function getCorrespondQuantity(uint amount) public view returns(uint){
//        uint allCorrespond = correspondBalance();
//        uint allCToken = totalSupply();
//        return amount.mul(allCorrespond).div(allCToken);
//    }
//
//    function stakeing(uint amount) external{
//        correspondToken.transferFrom(msg.sender,address(this),amount);
//        uint ctoken = getCTokenQuantity(amount);
//        _mint(msg.sender,ctoken);
//    }
//
//    function withdraw(uint amount) external{
////        _burnFrom(msg.sender,amount);
//        uint correspond = getCorrespondQuantity(amount);
//        correspondToken.transfer(msg.sender,correspond);
//    }
//
//
//}