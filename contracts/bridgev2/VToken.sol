// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./VERC20.sol";


contract CToken is VERC20{
    using SafeMath for uint;
    uint accrualBlockNumber;
    address mainCoin = address (0);
    mapping(address => uint) UserStakingAmount;

    address correspond;
    IERC20 correspondToken;

    function initialize(
        address correspond_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_) external {
        correspond = correspond_;
        correspondToken = IERC20(correspond);
        init(name_,symbol_,decimals_);
    }

    function correspondBalance() public view returns(uint){
        return IERC20(correspond).balanceOf(address(this));
    }

    function getCTokenQuantity(uint amount) public view returns(uint){
        uint allCorrespond = correspondBalance();
        uint allCToken = totalSupply();
        return amount.mul(allCToken).div(allCorrespond);
    }

    function getCorrespondQuantity(uint amount) public view returns(uint){
        uint allCorrespond = correspondBalance();
        uint allCToken = totalSupply();
        return amount.mul(allCorrespond).div(allCToken);
    }

    function stakeing(uint amount) external{
        correspondToken.transferFrom(msg.sender,address(this),amount);
        uint ctoken = getCTokenQuantity(amount);
        _mint(msg.sender,ctoken);
    }

    function withdraw(uint amount) external{
        _burn(msg.sender,amount);
        uint correspondAmount = getCorrespondQuantity(amount);
        correspondToken.transfer(msg.sender,correspondAmount);
    }
}