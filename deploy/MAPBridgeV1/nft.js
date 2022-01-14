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

  await deploy('NFTToken', {
    from: deployer.address,
    args: ["TestNFT","TNFT","0x0000000000000000000000000000000000000000",97],
    log: true,
    contract: 'NFTToken',
  })
  let wtoken = await ethers.getContract('NFTToken');

  console.log("NFTToken",wtoken.address);
}

module.exports.tags = ['nft']
