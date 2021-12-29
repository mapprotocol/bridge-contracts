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

  // await deploy('StandardToken', {
  //   from: deployer.address,
  //   args: ['Test token','TT'],
  //   log: true,
  //   contract: 'StandardToken',
  // })
  // let token = await ethers.getContract('StandardToken');
  //
  // console.log("StandardToken",token.address);

  await deploy('MAPBridgeV1', {
    from: deployer.address,
    args: [],
    log: true,
    contract: 'MAPBridgeV1',
  })
  let map = await ethers.getContract('MAPBridgeV1');

  console.log("MAPBridgeV1",map.address);


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

}

module.exports.tags = ['MAPBridgeV1']
