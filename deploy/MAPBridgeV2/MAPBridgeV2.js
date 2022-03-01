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

  await deploy('MAPBridgeV2', {
    from: deployer.address,
    args: [],
    log: true,
    contract: 'MAPBridgeV2',
  })
  let map = await ethers.getContract('MAPBridgeV2');

  console.log("MAPBridgeV2",map.address);



  await deploy('ProxyAdminImport', {
    from: deployer.address,
    args: [],
    log: true,
    contract: 'ProxyAdminImport',
  })
  let ProxyAdminImport = await ethers.getContract('ProxyAdminImport');

  console.log("ProxyAdminImport",ProxyAdminImport.address);

  const data = await ProxyAdminImport.getInitCallData(wcoin.address,mapcoin.address);

  console.log("data",data);

  await deploy('TransparentUpgradeableProxy', {
    from: deployer.address,
    args: [map.address,ProxyAdminImport.address,data],
    log: true,
    contract: 'TransparentUpgradeableProxy',
  })
  let TransparentUpgradeableProxy = await ethers.getContract('TransparentUpgradeableProxy');

  console.log("TransparentUpgradeableProxy address:", TransparentUpgradeableProxy.address);

  await deploy('FeeCenter', {
    from: deployer.address,
    args: [],
    log: true,
    contract: 'FeeCenter',
  })

  let FeeCenter = await ethers.getContract('FeeCenter');

  let bridgeV2 = await ethers.getContractAt('MAPBridgeV2',TransparentUpgradeableProxy.address);

  bridgeV2.setFeeCenter(FeeCenter.address);
}

module.exports.tags = ['MAPBridgeV2']
