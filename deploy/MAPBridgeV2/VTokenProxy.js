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

  let name = "VTetherToken"
  let symbol = "VUSDT"


  await deploy('VToken', {
    from: deployer.address,
    args: [],
    log: true,
    contract: 'VToken',
  })

  let VUSDT = await ethers.getContract('VToken');


  console.log("VUSDT:",VUSDT.address);



  await deploy('ProxyAdminImport', {
    from: deployer.address,
    args: [],
    log: true,
    contract: 'ProxyAdminImport',
  })
  let ProxyAdminImport = await ethers.getContract('ProxyAdminImport');

  console.log("ProxyAdminImport",ProxyAdminImport.address);

  await deploy('TransparentUpgradeableProxy', {
    from: deployer.address,
    args: [VUSDT.address,ProxyAdminImport.address,"0x"],
    log: true,
    contract: 'TransparentUpgradeableProxy',
  })
  let TransparentUpgradeableProxy = await ethers.getContract('TransparentUpgradeableProxy');

  console.log("TransparentUpgradeableProxy address:", TransparentUpgradeableProxy.address);

  let VUSDTProxy = await ethers.getContractAt('VToken',TransparentUpgradeableProxy.address);
  await VUSDTProxy.initialize("0xd505bfDB4f7FE74D4FfA0D641eDdFBe3A344a671",name,symbol,6);
}

module.exports.tags = ['VTokenProxy']
