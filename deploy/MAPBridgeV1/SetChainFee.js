const BigNumber = require('bignumber.js')
BigNumber.config({ ROUNDING_MODE: BigNumber.ROUND_FLOOR })
module.exports = async function ({ ethers, deployments}) {
  const { deploy } = deployments
  const { deployer} = await ethers.getNamedSigners()

  console.log(
      "Deploying contracts with the account:",
      await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());



  let TransparentUpgradeableProxy = await ethers.getContract('TransparentUpgradeableProxy')
  console.log(TransparentUpgradeableProxy.address);

  let bridge = await ethers.getContractAt("MAPBridgeV1",TransparentUpgradeableProxy.address)

  await bridge.setChainFee('3','100000000000000000')
  console.log(await bridge.chainGasFee('3'))
}

module.exports.tags = ['SetChainFee']
