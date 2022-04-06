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



  // await deploy('TetherToken', {
  //   from: deployer.address,
  //   args: ['1000000000000000000','TetherToken','USDT',6],
  //   log: true,
  //   contract: 'TetherToken',
  // })
  // let usdt = await ethers.getContract('TetherToken');
  //
  // console.log("usdt:",usdt.address);

  // await deploy('MintToken', {
  //   from: deployer.address,
  //   args: ['MintToken','MT'],
  //   log: true,
  //   contract: 'MintToken',
  // })
  let MintToken = await ethers.getContractAt('MintToken',"0x217f99f2933f6aa9e056740a8aaf903512c8f38a");

  console.log("MintToken:",MintToken.address);



  await MintToken.mint(deployer.address,'1000000000000000000000000')

  //
  // await deploy('MapToken', {
  //   from: deployer.address,
  //   args: ['MapToken','MAP'],
  //   log: true,
  //   contract: 'MapToken',
  // })
  // let MapToken = await ethers.getContract('MapToken');
  //
  // console.log("MapToken:",MapToken.address);
  //
  // await MapToken.mint(deployer.address,'1000000000000000000000000')


  // await deploy('EthToken', {
  //   from: deployer.address,
  //   args: ['EthToken','ETH'],
  //   log: true,
  //   contract: 'EthToken',
  // })
  // let EthToken = await ethers.getContract('EthToken');
  //
  // console.log("EthToken:",EthToken.address);
  //
  // await EthToken.mint(deployer.address,'1000000000000000000000000')


  // await deploy('BscToken', {
  //   from: deployer.address,
  //   args: ['BscToken','BNB'],
  //   log: true,
  //   contract: 'BscToken',
  // })
  // let BscToken = await ethers.getContract('BscToken');
  //
  // console.log("BscToken:",BscToken.address);
  //
  // BscToken.mint(deployer.address,'1000000000000000000000000')

}

module.exports.tags = ['TestTokenBsc']
