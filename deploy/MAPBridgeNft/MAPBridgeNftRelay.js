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

  await deploy('NFTBridgeRelay', {
    from: deployer.address,
    args: [],
    log: true,
    contract: 'NFTBridgeRelay',
  })
  let nftbridge = await ethers.getContract('NFTBridgeRelay');

  console.log("NFTBridgeRelay:", nftbridge.address);


  await deploy('FeeNFT', {
    from: deployer.address,
    args: [],
    log: true,
    contract: 'FeeNFT',
  })
  let feeNFT = await ethers.getContract('FeeNFT');

  console.log("FeeNFT:", feeNFT.address);

  await feeNFT.setChainNFTFee(22776,3,"10000000000000000");
  await feeNFT.setChainNFTFee(22776,97,"10000000000000000");
  console.log("setToChainNFTFee is ok : 22776")

  await feeNFT.setChainNFTFee(3,22776,"10000000000000000");
  await feeNFT.setChainNFTFee(3,97,"10000000000000000");
  console.log("setToChainNFTFee is ok : 3")

  await feeNFT.setChainNFTFee(97,3,"10000000000000000");
  await feeNFT.setChainNFTFee(97,22776,"10000000000000000");
  console.log("setToChainNFTFee is ok: 97")

  await feeNFT.setChainNativeToken(3,"0x05ab928d446d8ce6761e368c8e7be03c3168a9ec");
  console.log("setChainNativeToken is ok")

  await nftbridge.setFeeNFT(feeNFT.address);
  console.log("setFeeNFT is ok")


}

module.exports.tags = ['BridgeNFTRelay']
