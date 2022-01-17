// const { expect } = require("chai");
const { ethers } = require("hardhat")
const chai = require('chai')
const expect = chai.expect

describe("MAPBridgeV1", () => {
  before(async function (){
    const { deployer } = await ethers.getNamedSigners()
    this.deployer = deployer;


    this.bridge = await ethers.getContractAt('MAPBridgeRelayV1Only','0x346544CdCDB4452993d90e86ABCeAB8bD1405b7a');
    this.token = await ethers.getContract('StandardToken');
    this.usdt = await ethers.getContract("TetherToken");
    this.wtoken = await ethers.getContract("WrappedToken");

  })
  it("MAPBridgeV1", async function () {

    console.log(this.deployer.address)
    console.log("birdge:",this.bridge.address);
    console.log("usdt:",this.usdt.address);

    await this.token.mint(this.bridge.address,"100000000000000000000000000")

    const usdtBalance = await this.token.balanceOf(this.deployer.address)
    console.log(usdtBalance)


     await this.bridge.initialize(this.wtoken.address,this.token.address)

     await this.wtoken.deposit({value:1000});
     console.log("deposit ok")
     await this.wtoken.transfer(this.bridge.address,1000);
     console.log("transfer ok")

      this.usdt.approve(this.bridge.address,"100000000000")


    expect(usdtBalance).to.be.equal("10000000000000000000")



    await this.token.connect(this.deployer).approve(this.bridge.address,'1000000000000000000000000000')

    await this.token.grantRole("0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6",this.bridge.address)

    //address token, address to, uint amount, uint toChainId
    await this.bridge.transferOutToken(this.usdt.address,this.deployer.address,'1000000000',3,{value:"10000000000000000"});
    console.log("transferOutToken is ok")
    await this.bridge.transferOutTokenBurn(this.token.address,this.deployer.address,'10000000000000000000',22776)
    console.log("transferOutTokenBurn is ok")
    await this.bridge.transferOutNative(this.deployer.address,1000,22776,{value:1000})
    console.log("transferOutNative is ok")

    // function transferInToken(address token, address from, address payable to, uint amount, bytes32 orderId, uint fromChain, uint toChain)
    await this.bridge.transferInToken(this.token.address,this.deployer.address,
        this.deployer.address,'10000000000000000000','0x84b58192d78af4b8e92894444016ae129640ce3e2d41a02ebfebc3df7dafa934',97,22776)

    console.log("transferInToken is ok")

    await this.bridge.transferInTokenMint(this.token.address,this.deployer.address,
        this.deployer.address,'10000000000000000000','0x84b58192d78af4b8e92894444016ae129640ce3e2d41a02ebfebc3df7dafa935',97,22776)

    console.log("transferInTokenMint is ok")

    // (address from, address payable to, uint amount, bytes32 orderId, uint fromChain, uint toChain)
    await this.bridge.transferInNative(this.deployer.address,
        this.deployer.address,'100','0x84b58192d78af4b8e92894444016ae129640ce3e2d41a02ebfebc3df7dafa999','97','22776')


    // console.log("transferInNative is ok")
    // expect(await greeter.greet()).to.equal("Hello, world!");
    //
    // const setGreetingTx = await greeter.setGreeting("Hola, mundo!");
    //
    // // wait until the transaction is mined
    // await setGreetingTx.wait();
    //
    // expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
