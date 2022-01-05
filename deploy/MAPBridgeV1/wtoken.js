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

  await deploy('WrappedToken', {
    from: deployer.address,
    args: [],
    log: true,
    contract: 'WrappedToken',
  })
  let wtoken = await ethers.getContract('WrappedToken');

  console.log("WrappedToken",wtoken.address);


  await hre.run("verify:verify", {
      address: wtoken.address,
      constructorArguments:[]
  });
}

module.exports.tags = ['wtoken']
