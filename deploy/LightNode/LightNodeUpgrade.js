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

  const uupsProxy = await ethers.getContract('LightNodeProxy')

  console.log("LightNodeProxy address:", uupsProxy.address);

  const tx = await uupsProxy.upgradeTo(lightNode.address)
  console.log("txHash:", tx.hash);
  const receipt = await tx.wait();
  console.log('rec status:', receipt.status);
}

module.exports.tags = ['LightNodeUpgrade']
