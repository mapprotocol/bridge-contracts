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

  await deploy('StandardToken', {
    from: deployer.address,
    args: ['Test coin','TC'],
    log: true,
    contract: 'StandardToken',
  })
  let token = await ethers.getContract('StandardToken');

  console.log("StandardToken",token.address);

  // let bridge = await ethers.getContract('MAPBridgeV1');

  await token.grantRole("0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6","0x9C1Cc05BB8FCCC233c1E2a7832Bd64497fB0e630")


  await token.mint(deployer.address,"10000000000000000000000000000")

  // await hre.run("verify:verify", {
  //     address: token.address,
  //     constructorArguments:['Test coin','TC']
  // });

}

module.exports.tags = ['TokenMint']
