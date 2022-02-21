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

  await deploy('EthTest', {
    from: deployer.address,
    args: [],
    log: true,
    contract: 'EthTest',
  })
  let EthTest = await ethers.getContract('EthTest');

  console.log("EthTest",EthTest.address);


  await EthTest.transferOutNative(1,{value:1});
  console.log("transferOutNative ok")
  await EthTest.transferInNative(deployer.getAddress(),1)
  console.log("transferInNative ok")



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
    args: [EthTest.address,ProxyAdminImport.address,data],
    log: true,
    contract: 'TransparentUpgradeableProxy',
  })
  let TransparentUpgradeableProxy = await ethers.getContract('TransparentUpgradeableProxy');


  console.log("TransparentUpgradeableProxy address:", TransparentUpgradeableProxy.address);

  let abc = await ethers.getContractAt("EthTest",TransparentUpgradeableProxy.address)

  await abc.transferOutNative(1,{value:1});
  console.log(" proxy transferOutNative ok")
  await abc.transferInNative(deployer.getAddress(),1)
  console.log("proxy transferInNative ok")

}

module.exports.tags = ['ETE']
