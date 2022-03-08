// const { expect } = require("chai");
const { ethers } = require("hardhat")
const chai = require('chai')
const expect = chai.expect

describe("MAPBridgeV2", () => {
  before(async function (){
    const { deployer } = await ethers.getNamedSigners()
    this.deployer = deployer;


    //this.bridge = await ethers.getContractAt('MAPBridgeV2','0xD431A84e344667236c461D166B95c345fe1A920A');
    this.bridge = await ethers.getContractAt('MAPBridgeRelayV2','0xf3C3788FDa2470A32628a5EcFcD594d8f352438c');
    this.usdt = await ethers.getContract("TetherToken");
    this.mintToken = await ethers.getContract("MintToken");

  })
  it("MAPBridgeV2", async function () {

    console.log(this.deployer.address)
    console.log("birdge v2:",this.bridge.address);
    console.log("usdt:",this.usdt.address);
    console.log("mintToken:",this.mintToken.address);

    let amount = '1000000';

    // await this.mintToken.approve(this.bridge.address,'1000000000000000000000000000')
    // console.log("mintToken approve ok")
    // await this.usdt.approve(this.bridge.address,'1000000000000000000000000000')
    // console.log("usdt approve ok")
    //
    // await this.mintToken.grantRole("0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6",this.bridge.address)
    // console.log("mintToken grantRole ok")

    let feeCenter = await ethers.getContract("FeeCenter");
    await this.bridge.setFeeCenter(feeCenter.address);
    console.log("feeCenter setFeeCenter ok")

    await feeCenter.setDistributeRate(0,"0x0000000000000000000000000000000000000000",100)
    await feeCenter.setDistributeRate(1,"0x0000000000000000000000000000000000000001",100)
    console.log("feeCenter setDistributeRate ok")

    await feeCenter.setTokenVault(this.usdt.address,"0x0000000000000000000000000000000000000003")
    await feeCenter.setTokenVault(this.mintToken.address,"0x0000000000000000000000000000000000000004")
    console.log("feeCenter setTokenVault ok")


    // function transferOut(address token, address to, uint amount, uint toChainId) external
    await this.bridge.transferOut(this.usdt.address,this.deployer.address,amount,1);
    console.log("transferOutToken is ok")
    await this.bridge.transferOut(this.mintToken.address,this.deployer.address,amount,1)
    console.log("transferOutTokenBurn is ok")
    await this.bridge.transferOut("0x0000000000000000000000000000000000000000",this.deployer.address,1000,22776,{value:"1000"})
    console.log("transferOutNative is ok")


    // function transferIn(address token, address from, address payable to, uint amount, bytes32 orderId, uint fromChain, uint toChain)
    await this.bridge.transferIn(this.usdt.address,this.deployer.address,
        this.deployer.address,amount,'0x84b58192d78af4b8e92894444016ae129640ce3e2d41a02ebfebc3df7dafa001',97,3)
    console.log("transferInToken is ok")

    await this.bridge.transferIn(this.mintToken.address,this.deployer.address,
        this.deployer.address,amount,'0x84b58192d78af4b8e92894444016ae129640ce3e2d41a02ebfebc3df7dafa002',97,3)
    console.log("transferInTokenMint is ok")

    await this.bridge.transferIn("0x0000000000000000000000000000000000000000",this.deployer.address,
        this.deployer.address,"1000",'0x84b58192d78af4b8e92894444016ae129640ce3e2d41a02ebfebc3df7dafa003',97,3)
    console.log("transferInNative is ok")

  });
});
