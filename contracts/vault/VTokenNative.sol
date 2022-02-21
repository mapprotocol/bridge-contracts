// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./VERC20.sol";



contract VTokenNative is VERC20{
    using SafeMath for uint;
    uint accrualBlockNumber;
    address mainCoin = address (0);
    mapping(address => uint) UserStakingAmount;

    function initialize(
        string memory name_,
        string memory symbol_,
        uint8 decimals_) external {init(name_,symbol_,decimals_);
    }

    receive() payable external{
    }

    function correspondBalance() public view returns(uint){
        return payable(address(this)).balance;
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

    function staking() external payable{
        require(msg.value > 0,"value is empty");
        uint ctoken = getCTokenQuantity(msg.value);
        _mint(msg.sender,ctoken);
    }

    function withdraw(uint amount) external{
        _burn(msg.sender,amount);
        uint correspond = getCorrespondQuantity(amount);
        payable(address(msg.sender)).transfer(correspond);
    }


}