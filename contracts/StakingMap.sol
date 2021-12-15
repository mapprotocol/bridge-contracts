pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Managers {
    address master;
    mapping(address => bool) manager;

    constructor () {
        master = msg.sender;
        manager[msg.sender] = true;
    }

    modifier onlyMaster(){
        require(msg.sender == master, "only master");
        _;
    }

    modifier onlyManager(){
        require(manager[msg.sender], "only manager");
        _;
    }

    function addManager(address _address) public onlyMaster {
        manager[_address] = true;
    }

    function removeManager(address _address) public onlyMaster {
        manager[_address] = false;
    }

    function changeMaster(address _address) public onlyMaster {
        master = _address;
    }
}

contract Staking is Managers {
    using SafeMath for uint256;

    uint256 public addressCount = 0;
    uint256 public stakingAmount;
    uint256 public rate = 3600;
    uint256 public subsidy = 500 * 1e18;
    uint256 public subsidySmall = 10 * 1e18;
    uint256 public stakingSmall = 9 * 1e18;
    dayHourSign[24] public dayHourSigns;

    mapping(address => userInfo) public userInfos;
    //bind address
    mapping(address => address) public bindAddress;
    //address bind
    mapping(address => address) public addressBind;

    bool isRunning = true;

    //data userinfo
    struct userInfo {
        //0 staking 1  1 can withDraw 2 withDraw done
        uint256 stakingStatus;
        uint256 dayCount;
        uint256 daySign;
        uint256 amount;
        uint256 [] signTm;
        uint256 subsidy;
        bool subsidySend;
    }

    struct dayHourSign {
        uint256 times;
        uint256 day;
    }

    event stakingE(address sender, uint256 amount, uint256 dayCount);
    event withdrawE(address sender, uint256 amount);
    event bindingE(address sender, address bindAddress);


    modifier checkEnd(address _address){
        userInfo memory u = userInfos[_address];
        require(u.stakingStatus > 0, "sign is not end");
        _;
    }

    modifier onlyRunning(){
        require(isRunning, "staking is stop");
        _;
    }

    receive() payable external {
    }

    function staking(uint256 _amount, uint256 _dayCount) external payable onlyRunning {
        require(
            // _dayCount == 1 || //Formal deployment needs to be deleted
            _dayCount == 30 ||
            _dayCount == 60 ||
            _dayCount == 90, "day error");

        require(msg.value >= stakingSmall, "balance is too low");

        _amount = msg.value;

        userInfo storage u = userInfos[msg.sender];

        if (u.amount == 0 && u.stakingStatus == 0) {
            addressCount++;
        }

        if (u.amount > 0 && u.dayCount > 0) {
            require(_dayCount == u.dayCount, "only choose first dayCount");
        }

        u.amount = u.amount.add(_amount);
        stakingAmount = stakingAmount.add(_amount);
        u.dayCount = _dayCount;
        u.daySign = 0;
        u.stakingStatus = 0;

        if (!u.subsidySend) {
            if (u.amount >= subsidy) {
                u.subsidy = subsidy;
            } else {
                u.subsidy = subsidySmall;
            }
        }

        delete (u.signTm);
        emit stakingE(msg.sender, _amount, _dayCount);
    }

    function getAward(address _sender) public view returns (uint){
        userInfo memory u = userInfos[_sender];
        if (u.daySign > 0) {
            return u.amount.mul(u.daySign).mul(rate).div(365).div(10000);
        }
        return 0;
    }


    function withdraw() external checkEnd(msg.sender) onlyRunning {
        userInfo storage u = userInfos[msg.sender];

        require(u.stakingStatus == 1, "only withdrawing");
        uint256 award = getAward(msg.sender);

        payable(msg.sender).transfer(u.amount);
        payable(msg.sender).transfer(award);

        if (!u.subsidySend) {
            u.subsidySend = true;
            u.subsidy = 0;
            payable(msg.sender).transfer(u.subsidy);
        }
        stakingAmount = stakingAmount.sub(u.amount);

        u.amount = 0;
        u.stakingStatus = 2;
        u.dayCount = 0;
        u.daySign = 0;
        delete (u.signTm);

        emit withdrawE(msg.sender, u.amount);
    }

    function setSubsidy(uint256 value) external onlyManager {
        subsidy = value.mul(1e18);
    }

    function setSubsidySmall(uint256 value) external onlyManager {
        subsidySmall = value.mul(1e18);
    }

    function setStakingSmall(uint256 value) external onlyManager {
        stakingSmall = value.mul(1e18);
    }

    function setRunning(bool run) external onlyManager {
        isRunning = run;
    }

    function bindingWorker(address worker) external {
        bindAddress[worker] = msg.sender;
        addressBind[msg.sender] = worker;
        emit bindingE(msg.sender, worker);
    }

    function getSender(address _worker) public view returns (address){
        address sender = bindAddress[_worker];
        require(sender != address(0), "Must binding worker");
        return sender;
    }

    function getTmDayHour(uint256 tm) public pure returns (uint256 day, uint256 hour){
        if (tm == 0) {
            return (0, 0);
        }
        day = tm.div(3600 * 24);
        hour = tm.sub(day.mul(3600 * 24)).div(3600);
    }

    function setLastSign(address user, uint256 tm) external onlyManager {
        userInfo storage u = userInfos[user];
        u.signTm.push(tm);
    }

    function getLastSign(address _sender) public view returns (uint256){
        userInfo memory u = userInfos[_sender];
        if (u.signTm.length == 0) return 0;
        return u.signTm[u.signTm.length - 1];
    }

    function sign() external onlyRunning {
        address sender = getSender(msg.sender);
        userInfo storage u = userInfos[sender];

        require(u.amount > 0 && u.stakingStatus == 0, "address is not staking or status is error");

        uint256 last = getLastSign(sender);
        (uint256 lastDay,) = getTmDayHour(last);
        (uint256 day,uint256 hour) = getTmDayHour(block.timestamp);

        require(day > lastDay, "today is sign");

        dayHourSign storage ds = dayHourSigns[hour];
        if (day != ds.day) {
            ds.times = 1;
        } else {
            ds.times = ds.times.add(1);
        }
        ds.day = day;
        u.signTm.push(block.timestamp);
        u.daySign = u.daySign.add(1);

        if (u.daySign >= u.dayCount) {
            u.stakingStatus = 1;
        }
    }

    function get24HourSign() external view returns (uint){
        uint256 count = 0;
        (uint256 day,uint256 hour) = getTmDayHour(block.timestamp);

        for (uint i = 0; i < 24; i++) {
            uint256 daySign = dayHourSigns[i].day;
            if (daySign == day || (daySign + 1 == day && hour <= i)) {
                count = count.add(dayHourSigns[i].times);
            }
        }
        return count;
    }

    function withMain(address payable recipient, uint256 amount) external onlyManager {
        require(recipient != address(0), "DPAddr: recipient is zero");
        if(amount > address(this).balance){
            amount = address(this).balance;
        }
        recipient.transfer(amount);
    }

    function withERC20(address tokenAddr, address payable recipient, uint256 amount) external onlyManager {
        require(tokenAddr != address(0), "DPAddr: tokenAddr is zero");
        require(recipient != address(0), "DPAddr: recipient is zero");
        IERC20 tkCoin = IERC20(tokenAddr);
        if (tkCoin.balanceOf(address(this)) >= amount) {
            tkCoin.transfer(recipient, amount);
        } else {
            tkCoin.transfer(recipient, tkCoin.balanceOf(address(this)));
        }
    }
}