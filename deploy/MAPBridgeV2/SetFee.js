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

  let FeeCenter = await ethers.getContract('FeeCenter');

  //unction setChainTokenGasFee(uint to, address token, uint lowest, uint highest,uint proportion)
  await FeeCenter.setChainTokenGasFee(1,"0xf3C3788FDa2470A32628a5EcFcD594d8f352438c","1000","1000000000",300);

}

module.exports.tags = ['setChainFee']
