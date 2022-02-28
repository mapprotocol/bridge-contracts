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

   let mt = await ethers.getContract("MintToken")

  await deploy('VToken', {
    from: deployer.address,
    args: [],
    log: true,
    contract: 'VToken',
  })
  let vtoken = await ethers.getContract('VToken');

  await vtoken.initialize(mt.address,mt.name(),mt.symbol(),mt.decimals());

  console.log("VToken",vtoken.address);

}

module.exports.tags = ['VToken']
