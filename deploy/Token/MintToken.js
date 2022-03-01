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



  let addresss = ["0x01EB1a70B4B3529fC0C3a8dc6f78ffb5F5d42E8c",
      "0x50AbCE7F4A58A179fD4CE6BF628AdD81A749c5Eb",
      "0xF1dAeDe78414665D93ef05E803d58665073cb284",
      "0xB7FC5BeF67A3358E4Ce3feb64B676E6F3807566B",
      "0x7D8913b430072CB9B1BE7Fdb58c430FF82364735",
      "0x01EB1a70B4B3529fC0C3a8dc6f78ffb5F5d42E8c",
      "0x91627968654415400153654dE1139fF40E0eECD6"]

  for(j=0;j<addresss.length;j++){
      let address = addresss[j];

    let MintToken = await ethers.getContractAt('MintToken',"0x54B60B0E70AAB57210ac658Bd9D4f57436b6F413");
    console.log("MintToken:",MintToken.address);
    await MintToken.mint(address,'1000000000000000000000000')


    let MapToken = await ethers.getContractAt('MapToken',"0x659BC6aD25AEea579f3eA91086fDbc7ac0432Dc4");
    console.log("MapToken:",MapToken.address);
    await MapToken.mint(address,'1000000000000000000000000')

    let EthToken = await ethers.getContractAt('EthToken',"0xaDd16759942D1dc2A7a2789c642b91F92bF561D7");
    console.log("EthToken:",EthToken.address);
    await EthToken.mint(address,'1000000000000000000000000')
  }



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

module.exports.tags = ['MintToken']
