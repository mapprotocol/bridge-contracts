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

  await deploy('Token2', {
    from: deployer.address,
    args: [deployer.address],
    log: true,
    contract: 'Token2',
  })
  let token = await ethers.getContract('Token2');

  console.log("Token2",token.address);


  await hre.run("verify:verify", {
      address: token.address,
      constructorArguments:[deployer.address]
  });

}

module.exports.tags = ['TokenMint']
