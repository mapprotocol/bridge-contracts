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
  let MintToken = await ethers.getContract('MintToken');

  console.log("MintToken:",MintToken.address);

  let authToken =[];
  authToken.push(MintToken.address);

  console.log(authToken)

  // let bridgeV2 = await ethers.getContractAt('MAPBridgeRelayV2',"0xf3C3788FDa2470A32628a5EcFcD594d8f352438c");
  //
  // await bridgeV2.addAuthToken(authToken);

  let bridge = await ethers.getContractAt('MAPBridgeV2','0xD431A84e344667236c461D166B95c345fe1A920A');
  await bridge.addAuthToken(authToken);


}

module.exports.tags = ['AddAuthToken']
