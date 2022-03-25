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


  await VUSDT.initialize(this.usdt.address,name,symbol,6);

  console.log("VUSDT:",VUSDT.address);

  // name = "VMintToken"
  // symbol = "VMT"
  //
  // await deploy('VToken2', {
  //   from: deployer.address,
  //   args: [],
  //   log: true,
  //   contract: 'VToken2',
  // })
  // let VMT = await ethers.getContract('VToken2');
  //
  // await VMT.initialize(this.token.address,name,symbol,18);
  //
  //
  // console.log("VMT:",VMT.address);
}

module.exports.tags = ['VaultToken']
