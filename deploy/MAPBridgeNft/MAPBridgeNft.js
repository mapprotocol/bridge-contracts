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

  await deploy('NFTBridge', {
    from: deployer.address,
    args: [],
    log: true,
    contract: 'NFTBridge',
  })
  let map = await ethers.getContract('NFTBridge');

  console.log("NFTBridge",map.address);

}

module.exports.tags = ['Bridge']
