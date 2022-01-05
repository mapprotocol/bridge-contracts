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


  await deploy('MAPBridgeRelayV1Only', {
    from: deployer.address,
    args: [],
    log: true,
    contract: 'MAPBridgeRelayV1Only',
  })
  let MAPBridgeRelayV1Only = await ethers.getContract('MAPBridgeRelayV1Only');

  console.log("MAPBridgeRelayV1",MAPBridgeRelayV1Only.address);


  let ProxyAdminImport = await ethers.getContract('ProxyAdminImport');

  console.log("ProxyAdminImport",ProxyAdminImport.address);

  let TransparentUpgradeableProxy = await ethers.getContract('TransparentUpgradeableProxy');

  console.log("TransparentUpgradeableProxy address:", TransparentUpgradeableProxy.address);

  await ProxyAdminImport.upgrade(TransparentUpgradeableProxy.address,MAPBridgeRelayV1Only.address)

  let bridge = await ethers.getContractAt("MAPBridgeV1",TransparentUpgradeableProxy.address)

  await bridge.setChainFee('1','1500000000000000000000')
}

module.exports.tags = ['RelayUpgrade']
