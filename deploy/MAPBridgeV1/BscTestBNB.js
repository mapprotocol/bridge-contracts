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

  await deploy('BscTest', {
    from: deployer.address,
    args: [],
    log: true,
    contract: 'BscTest',
  })
  let BscTest = await ethers.getContract('BscTest');

  console.log("BscTest",BscTest.address);


  await BscTest.transferOutNative(1,{value:1});
  console.log("transferOutNative ok")
  await BscTest.transferInNative(deployer.getAddress(),1)
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
    args: [BscTest.address,ProxyAdminImport.address,data],
    log: true,
    contract: 'TransparentUpgradeableProxy',
  })
  let TransparentUpgradeableProxy = await ethers.getContract('TransparentUpgradeableProxy');


  console.log("TransparentUpgradeableProxy address:", TransparentUpgradeableProxy.address);

  let abc = await ethers.getContractAt("BscTest",TransparentUpgradeableProxy.address)

  await abc.transferOutNative(1,{value:1});
  console.log(" proxy transferOutNative ok")
  await abc.transferInNative(deployer.getAddress(),1)
  console.log(" proxy transferInNative ok")

}

module.exports.tags = ['BTB']
