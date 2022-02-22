const BigNumber = require('bignumber.js')
BigNumber.config({ ROUNDING_MODE: BigNumber.ROUND_FLOOR })
module.exports = async function ({ ethers, getNamedAccounts, deployments}) {
  const { deploy } = deployments
  const { deployer } = await ethers.getNamedSigners()

  console.log(
      "Deploying contracts with the account:",
      await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());


  let mapbridgeProxy = await ethers.getContract('TransparentUpgradeableProxy');

  console.log("mapbridgeProxy",mapbridgeProxy.address);

  let mapbridge = await ethers.getContractAt("MAPBridgeV1",mapbridgeProxy.address);

  console.log("Load MAPBridgeV1 for", mapbridgeProxy.address);

  let manager = "";

  await mapbridge.addManager(manager)

  console.log("Add manager:", manager);

}

module.exports.tags = ['BridgeAddManager']
