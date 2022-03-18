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

  let mapToken = await ethers.getContract('MapToken');

  await deploy('MasterChef', {
    from: deployer.address,
    args: [mapToken.address,"1000000000000000000",1694633,2694633],
    log: true,
    contract: 'MasterChef',
  })

  let pool = await ethers.getContract("MasterChef");

  let VMT = await ethers.getContract('VToken2');

  let VUSDT = await ethers.getContract('VToken');


  await pool.add(1,VMT.address,true)
  console.log("add vmt ok")
  await pool.add(1,VUSDT.address,true)
  console.log("add vusdt ok")
}

module.exports.tags = ['RewardPool']
