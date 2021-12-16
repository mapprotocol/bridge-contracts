pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED
// Vote and run Router swapIn

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract StakingVote is Ownable {
    using SafeMath for uint;

    address public stakingCoin;
    uint public lockTime = 15 days;

    uint public allStaking;

    struct staking {
        uint amount;
        uint lock;
        uint withdrawTime;
    }

    mapping(address => staking) userStaking;

    struct vote {
        uint totalVoteAmount;
        uint haveVoteAmount;
        mapping(address => uint) userVote;
    }

    mapping(bytes32 => vote) txVotes;


    event LogStake(address from, address coin, uint amount);
    event LogUnStake(address from, address coin, uint amount);
    event LogWithDraw(address from, address coin, uint amount);
    event LogVote(address from, address coin, uint amount, bytes32 tx);

    constructor(address coin){
        stakingCoin = coin;
    }

    modifier onlyStaking(address sender){
        require(userStaking[sender].amount > 0, "only staking");
        _;
    }

    modifier canVote(bytes32 txId) {
        vote storage v = txVotes[txId];
        require(v.haveVoteAmount < v.totalVoteAmount, "vote is compile");
        _;
    }

    modifier canWithdraw(address sender){
        staking memory v = userStaking[sender];
        require(v.withdrawTime != 0 && v.withdrawTime < block.timestamp, "Withdrawal time is up");
        _;
    }

    function _stake(address sender, uint amount) private {
        staking storage stak = userStaking[sender];
        stak.amount = stak.amount.add(amount);
        allStaking = allStaking.add(amount);
        emit LogStake(sender, stakingCoin, amount);
    }

    function stake(uint amount) external payable {
        if (stakingCoin == address(0)) {
            require(msg.value == amount, "amount is error");
        } else {
            IERC20(stakingCoin).transferFrom(msg.sender, address(this), amount);
        }
        _stake(msg.sender, amount);
    }


    function withdraw() external canWithdraw(msg.sender) {
        uint amount = _withdraw();
        if (stakingCoin == address(0)) {
            payable(msg.sender).transfer(amount);
        } else {
            IERC20(stakingCoin).transfer(msg.sender, amount);
        }
        _withdraw();
    }

    function _withdraw() private returns (uint){
        staking storage stak = userStaking[msg.sender];
        uint amount = stak.lock;
        stak.lock = 0;
        stak.withdrawTime = block.timestamp;
        emit LogUnStake(msg.sender, stakingCoin, amount);
        return amount;
    }

    function unStaking(uint amount) external {
        _unStaking(amount);
    }

    function _unStaking(uint amount) private {
        staking storage stak = userStaking[msg.sender];
        require(amount <= stak.amount, "not have amount");
        stak.amount = stak.amount.sub(amount);
        stak.lock = stak.lock.add(amount);
        stak.withdrawTime = block.timestamp.add(lockTime);
    }

    function checkVoteAmount(uint have, uint all) public pure returns (bool){
        return have > (all.mul(2).div(3));
    }

    function voteTx(bytes32 hash, address voter) onlyStaking(voter) canVote(hash) external returns (bool){
        vote storage v = txVotes[hash];
        if (v.totalVoteAmount == 0) {
            v.totalVoteAmount = allStaking;
        }
        uint amount = userStaking[voter].amount;
        v.haveVoteAmount = v.haveVoteAmount.add(amount);
        LogVote(voter, stakingCoin, amount, hash);
        return checkVoteAmount(v.haveVoteAmount, v.totalVoteAmount);
    }

}
