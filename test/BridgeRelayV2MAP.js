// const { expect } = require("chai");
const { ethers } = require("hardhat")
const chai = require('chai')
const expect = chai.expect

describe("MAPBridgeV2", () => {
  before(async function (){
    const { deployer, wcoin } = await ethers.getNamedSigners()
    this.deployer = deployer;
    this.wcoin = wcoin;

    //this.bridge = await ethers.getContractAt('MAPBridgeV2','0xD431A84e344667236c461D166B95c345fe1A920A');
    this.bridge = await ethers.getContractAt('MAPBridgeRelayV2','0x8084d0C99217221a8d233B3162C724F676295982');
    this.usdt = await ethers.getContract("TetherToken");
    this.mintToken = await ethers.getContract("MintToken");
    this.vusdt = await ethers.getContract("VToken");
    this.vmt = await ethers.getContract("VToken2");

  })
  it("MAPBridgeV2", async function () {

    console.log(this.deployer.address)
    console.log("birdge v2:",this.bridge.address);
    console.log("usdt:",this.usdt.address);
    console.log("mintToken:",this.mintToken.address);
    console.log("vusdt:",this.vusdt.address)
    console.log("vmt:",this.vmt.address);

    // await this.bridge.setVaultBalance(1,this.usdt.address,"10000000000");
    // await this.bridge.setVaultBalance(97,this.usdt.address,"10000000000");
    // await this.bridge.setVaultBalance(22776,this.usdt.address,"10000000000");

    let amount = '1000000';
    let amountIn = '10000000';

    await this.mintToken.approve(this.bridge.address,'1000000000000000000000000000')
    console.log("mintToken approve ok")
    await this.usdt.approve(this.bridge.address,'8000000000000000000000000000')
    console.log("usdt approve ok")

    await this.mintToken.grantRole("0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6",this.bridge.address)
    console.log("mintToken grantRole ok")

    let feeCenter = await ethers.getContract("FeeCenter");
    console.log("feeCenter",feeCenter.address.toString())
    await this.bridge.setFeeCenter(feeCenter.address);
    console.log("feeCenter setFeeCenter ok")

    await feeCenter.setDistributeRate(0,"0x0000000000000000000000000000000000000000",100)
    await feeCenter.setDistributeRate(1,"0x0000000000000000000000000000000000000001",100)
    console.log("feeCenter setDistributeRate ok")

    await feeCenter.setTokenVault(this.usdt.address,this.vusdt.address)
    await feeCenter.setTokenVault(this.mintToken.address,this.vmt.address)
    console.log("feeCenter setTokenVault ok")

    // function setChainTokenGasFee(uint to, address token, uint lowest, uint highest,uint proportion)
    await feeCenter.setChainTokenGasFee(1,this.wcoin.address,1,10000,100);
    await feeCenter.setChainTokenGasFee(1,this.mintToken.address,1,10000,100);
    await feeCenter.setChainTokenGasFee(1,this.usdt.address,1,10000,100);

    await feeCenter.setChainTokenGasFee(97,this.wcoin.address,1,10000,100);
    await feeCenter.setChainTokenGasFee(97,this.mintToken.address,1,10000,100);
    await feeCenter.setChainTokenGasFee(97,this.usdt.address,1,10000,100);

    console.log("feeCenter setChainTokenGasFee ok")

    await feeCenter.addManager(this.bridge.address)
    console.log("feeCenter addManager ok")



    await this.bridge.setVaultBalance(1,this.usdt.address,"10000000000000000000000000");
    await this.bridge.setVaultBalance(97,this.usdt.address,"10000000000000000000000000");
    await this.bridge.setVaultBalance(22776,this.usdt.address,"10000000000000000000000000");
    await this.bridge.setVaultBalance(1,this.mintToken.address,"10000000000000000000000000");
    await this.bridge.setVaultBalance(97,this.mintToken.address,"10000000000000000000000000");
    await this.bridge.setVaultBalance(22776,this.mintToken.address,"10000000000000000000000000");
    await this.bridge.setVaultBalance(1,"0x0000000000000000000000000000000000000000","10000000000000000000000000");
    await this.bridge.setVaultBalance(97,"0x0000000000000000000000000000000000000000","10000000000000000000000000");
    await this.bridge.setVaultBalance(22776,"0x0000000000000000000000000000000000000000","10000000000000000000000000");

    console.log("set vault balance is ok")


    let authToken =[];
    authToken.push(this.mintToken.address);
    await this.bridge.addAuthToken(authToken)

    console.log("add mintToken auth ok")


    // function transferOut(address token, address to, uint amount, uint toChainId) external
    await this.bridge.transferOut(this.usdt.address,this.deployer.address,amountIn,1);
    console.log("transferOutToken is ok")
    await this.bridge.transferOut(this.mintToken.address,this.deployer.address,amountIn,1)
    console.log("transferOutTokenBurn is ok")
    await this.bridge.transferOutNative("0x0000000000000000000000000000000000000000",1,{value:"10000"})
    console.log("transferOutNative is ok")


    // function transferIn(address token, address from, address payable to, uint amount, bytes32 orderId, uint fromChain, uint toChain)
    await this.bridge.transferIn(this.usdt.address,this.deployer.address,
        this.deployer.address,amount,'0x84b58192d78af4b8e92894444016ae129640ce3e2d41a02ebfebc3df7dafa014',97,1)
    console.log("transferInToken is ok")

    await this.bridge.transferIn(this.mintToken.address,this.deployer.address,
        this.deployer.address,amount,'0x84b58192d78af4b8e92894444016ae129640ce3e2d41a02ebfebc3df7dafa015',97,1)
    console.log("transferInTokenMint is ok")

    await this.bridge.transferIn("0x0000000000000000000000000000000000000000",this.deployer.address,
        this.deployer.address,"1000",'0x84b58192d78af4b8e92894444016ae129640ce3e2d41a02ebfebc3df7dafa016',97,1)
    console.log("transferInNative is ok")


    // function transferIn(address token, address from, address payable to, uint amount, bytes32 orderId, uint fromChain, uint toChain)
    await this.bridge.transferIn(this.usdt.address,this.deployer.address,
        this.deployer.address,amount,'0x84b58192d78af4b8e92894444016ae129640ce3e2d41a02ebfebc3df7dafa017',1,22776)
    console.log("transferInToken self is ok")

    await this.bridge.transferIn(this.mintToken.address,this.deployer.address,
        this.deployer.address,amount,'0x84b58192d78af4b8e92894444016ae129640ce3e2d41a02ebfebc3df7dafa012',1,22776)
    console.log("transferInTokenMint self is ok")

    await this.bridge.transferIn("0x0000000000000000000000000000000000000000",this.deployer.address,
        this.deployer.address,"1000",'0x84b58192d78af4b8e92894444016ae129640ce3e2d41a02ebfebc3df7dafa013',1,22776)
    console.log("transferInNative self is ok")

    return;
  });
});
