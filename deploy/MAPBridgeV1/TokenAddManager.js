const BigNumber = require('bignumber.js')
BigNumber.config({ ROUNDING_MODE: BigNumber.ROUND_FLOOR })
module.exports = async function ({ ethers, getNamedAccounts, deployments}) {
  const { deploy } = deployments
  const { deployer } = await ethers.getNamedSigners()
  const {usdt,usdc,eth,idv} = await getNamedAccounts();

  console.log(
      "Deploying contracts with the account:",
      await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  await deploy('MAPBridgeRelayV1', {
    from: deployer.address,
    args: [],
    log: true,
    contract: 'MAPBridgeV1',
  })

  let mapbridge = await ethers.getContract('MAPBridgeRelayV1');

  console.log("MAPBridgeRelayV1",mapbridge.address);


  let usdtcoin = await ethers.getContractAt("Token",usdt);

  console.log("usdt:",usdt);

  let minterRole = await usdtcoin.MINTER_ROLE();

  console.log("minte role:", minterRole);

  await usdtcoin.grantRole(minterRole,mapbridge.address);
  console.log("usdt add minter ok")

  let usdccoin = await ethers.getContractAt("Token",usdc);
  await usdccoin.grantRole(minterRole,mapbridge.address);

  console.log("usdt add minter ok")
  let ethcoin = await ethers.getContractAt("Token",eth);
  await ethcoin.grantRole(minterRole,mapbridge.address);

  console.log("eth add minter ok")
  let idvcoin = await ethers.getContractAt("Token",idv);
  await idvcoin.grantRole(minterRole,mapbridge.address);

  console.log("idv add minter ok")


}

module.exports.tags = ['AddManager']
