module.exports = async function ({ ethers, deployments}) {
  const { deploy } = deployments
  const { deployer } = await ethers.getNamedSigners()

  console.log(
      "Deploying contracts with the account:",
      await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const lightNode = await deploy('LightNode', {
    from: deployer.address,
    args: [],
    log: true,
  })

  console.log("LightNode", lightNode.address);

  // const lightNodeContract = await ethers.getContractAt(lightNode.abi, lightNode.address);
  // const data = lightNodeContract.interface.encodeFunctionData('initialize',['0x00',0]);
  // console.log("data",data);
  const data = 0;

  const uupsProxy = await deploy('LightNodeProxy', {
    from: deployer.address,
    args: [lightNode.address, data],
    log: true,
  })

  console.log("LightNodeProxy", uupsProxy.address);
}

module.exports.tags = ['LightNode']
