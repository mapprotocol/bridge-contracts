pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED
// Vote and run Router swapIn

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract StakingVote is Ownable{
    using SafeMath for uint;

    address public stakingCoin;

    uint public allStaking;
    mapping(address => uint) userStaking;

    struct vote{
        uint totalVoteAmount;
        uint havaVoteAmount;
        mapping(address => uint) userVote;
    }

    mapping (bytes32 => vote) txVotes;


    event LogStake(address from, address coin, uint amount);
    event LogUnStake(address from, address coin, uint amount);
    event LogVote(address from, address coin, uint amount,bytes32 tx);

    constructor(address coin){
        stakingCoin = coin;
    }

    modifier onlyStaking(address sender){
        require(userStaking[sender] > 0,"only staking");
        _;
    }

    modifier canVote(bytes32 txId) {
        vote storage v = txVotes[txId];
        require(v.havaVoteAmount < v.totalVoteAmount,"vote is compile");
        _;
    }

    function stake(address sender, uint amount) private{
        userStaking[sender] = userStaking[sender].add(amount);
        allStaking = allStaking.add(amount);
        emit LogStake(sender,stakingCoin,amount);
    }

    function staking(uint amount) external payable{
        if (stakingCoin == address(0)){
            require(msg.value == amount, "amount is error");
        }else{
            IERC20(stakingCoin).transferFrom(msg.sender,address(this),amount);
        }
        stake(msg.sender,amount);
    }

    function unStake(address sender, uint amount) private{
        userStaking[sender] = userStaking[sender].sub(amount);
        allStaking = allStaking.sub(amount);
        emit LogUnStake(sender,stakingCoin,amount);
    }

    function unStaking(uint amount) external{
        require(amount <= userStaking[msg.sender],"not have amount");
        if (stakingCoin == address(0)){
            payable(msg.sender).transfer(amount);
        }else{
            IERC20(stakingCoin).transfer(msg.sender,amount);
        }
        unStake(msg.sender,amount);
    }

    function checkVoteAmount(uint have,uint all) public pure returns(bool){
        return have > (all.mul(2).div(3));
    }

    function voteTx(bytes32 hash) onlyStaking(msg.sender) canVote(hash) external returns(bool){
        vote storage v = txVotes[hash];
        if (v.totalVoteAmount == 0){
            v.totalVoteAmount = allStaking;
        }
        uint amount = userStaking[msg.sender];
        v.havaVoteAmount = v.havaVoteAmount.add(amount);
        LogVote(msg.sender,stakingCoin,amount,hash);
        return checkVoteAmount(v.havaVoteAmount,v.totalVoteAmount);
    }

}
