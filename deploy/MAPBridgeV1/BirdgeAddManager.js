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


  let mapbridge = await ethers.getContract('TransparentUpgradeableProxy');

  console.log("MAPBridgeV1",mapbridge.address);

  let manager = "";

  await mapbridge.addManager(manager)

  console.log("Add manager:", manager);

}

module.exports.tags = ['BridgeAddManager']
