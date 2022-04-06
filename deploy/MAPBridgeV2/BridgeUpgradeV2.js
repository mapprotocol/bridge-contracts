const BigNumber = require('bignumber.js')
BigNumber.config({ ROUNDING_MODE: BigNumber.ROUND_FLOOR })
module.exports = async function ({ ethers, deployments}) {
  const { deploy } = deployments
  const { deployer,wcoin,mapcoin} = await ethers.getNamedSigners()

  console.log(
      "Deploying contracts with the account:",
      await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());


  await deploy('MAPBridgeV2', {
    from: deployer.address,
    args: [],
    log: true,
    contract: 'MAPBridgeV2',
  })
  let MAPBridgeV1 = await ethers.getContract('MAPBridgeV2');

  console.log("MAPBridgeV2",MAPBridgeV1.address);


  let ProxyAdminImport = await ethers.getContract('ProxyAdminImport');

  console.log("ProxyAdminImport",ProxyAdminImport.address);

  let TransparentUpgradeableProxy = await ethers.getContract('TransparentUpgradeableProxy');

  console.log("TransparentUpgradeableProxy address:", TransparentUpgradeableProxy.address);

  await ProxyAdminImport.upgrade(TransparentUpgradeableProxy.address,MAPBridgeV1.address)

}

module.exports.tags = ['BridgeUpgradeV2']
