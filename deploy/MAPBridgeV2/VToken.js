const BigNumber = require('bignumber.js')
BigNumber.config({ ROUNDING_MODE: BigNumber.ROUND_FLOOR })
module.exports = async function ({ ethers, deployments}) {
  const { deploy } = deployments
  const { deployer ,wcoin,mapcoin } = await ethers.getNamedSigners()

  console.log(
      "Deploying contracts with the account:",
      await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());


  this.token = await ethers.getContract('MintToken');
  this.usdt = await ethers.getContract("TetherToken");
  this.bridge = await ethers.getContract("MAPBridgeRelayV2");

  let name = "VTetherToken"
  let symbol = "VUSDT"


  await deploy('VToken', {
    from: deployer.address,
    args: [],
    log: true,
    contract: 'VToken',
  })

  let VUSDT = await ethers.getContract('VToken');

  VUSDT.initialize(this.usdt.address,name,symbol,6);

  console.log("VUSDT:",VUSDT.address);


  name = "VMintToken"
  symbol = "VMT"


  await deploy('VToken2', {
    from: deployer.address,
    args: [],
    log: true,
    contract: 'VToken2',
  })
  let VMT = await ethers.getContract('VToken2');

  VMT.initialize(this.token.address,name,symbol,18);




  // USDT: 0xd505bfDB4f7FE74D4FfA0D641eDdFBe3A344a671
  //
  // VUSDT: 0xA818531cbcc4b93176493d6f932447294Dce9635
  //
  // MintToken: 0xd6a9f83A761D79d2448F0EB347E2CbF7c227bd6d

  // let VUSDT = await ethers.getContract('VToken');
  // let VWM = await ethers.getContract('VToken2');
  // this.bridge = await ethers.getContract("MAPBridgeRelayV2");
  //
  // await VUSDT.addManager("0x8084d0C99217221a8d233B3162C724F676295982")
  // await VWM.addManager("0x8084d0C99217221a8d233B3162C724F676295982")

  console.log("VMT:",VMT.address);
}

module.exports.tags = ['VaultToken']
