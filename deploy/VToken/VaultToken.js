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

  await deploy('MintToken', {
    from: deployer.address,
    args: ['MintToken','MT'],
    log: true,
    contract: 'MintToken',
  })

  let mt = await ethers.getContract("MintToken")

  let name = await mt.name();
  let symbol = await mt.symbol();


  await mt.mint(deployer.address,"10000000000000000000000000000000")

  await deploy('VToken', {
    from: deployer.address,
    args: [],
    log: true,
    contract: 'VToken',
  })
  let vtoken = await ethers.getContract('VToken');

  await mt.approve(vtoken.address,"100000000000000000000000000000000")

  await vtoken.initialize(mt.address,"V".concat(name),"V".concat(symbol),mt.decimals());

  await hre.run("verify:verify", {
    address: vtoken.address,
    constructorArguments:[]
  });

  console.log("VToken",vtoken.address);

}

module.exports.tags = ['VToken']
