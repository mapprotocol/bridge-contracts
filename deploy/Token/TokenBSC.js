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



  await deploy('MintToken', {
    from: deployer.address,
    args: ['Mapped Binance USD','BUSD'],
    log: true,
    contract: 'MintToken',
  })
  let IDVToken = await ethers.getContract('MintToken');

  console.log("IDVToken:",IDVToken.address);


  await deploy('MintToken', {
    from: deployer.address,
    args: ['Mapped BNB','BNB'],
    log: true,
    contract: 'MintToken',
  })
  let MAPToken = await ethers.getContract('MintToken');

  console.log("MAPToken:",MAPToken.address);


}

module.exports.tags = ['TokenBsc']
