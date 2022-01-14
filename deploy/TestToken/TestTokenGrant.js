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


/*
  await deploy('MintToken', {
    from: deployer.address,
    args: ['MintToken','MT'],
    log: true,
    contract: 'MintToken',
  })
  */
  let MintIdvToken = await ethers.getContractAt('MintToken', "0x35bF4004C3Fc9f509259d4942da6bae3669e1Db1");

  console.log("MintToken:",MintIdvToken.address);

  let MintMapToken = await ethers.getContractAt('MintToken', "0xA0d5b155aE8226640D0CB6652151Ef19bE2a70c5");

  console.log("MintToken:",MintMapToken.address);

  let bridge = await ethers.getContract('TransparentUpgradeableProxy');

  await MintIdvToken.grantRole("0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6",bridge.address)

  await MintMapToken.grantRole("0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6",bridge.address)

}

module.exports.tags = ['TestTokenGrant']
