module.exports = async function ({ ethers, deployments}) {
  const { deploy } = deployments
  const { deployer } = await ethers.getNamedSigners()

  console.log(
      "Deploying contracts with the account:",
      await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const relayer = await deploy('Relayer', {
    from: deployer.address,
    args: [],
    log: true,
  })

  console.log("Relayer", relayer.address);


  const proxyAdmin = await ethers.getContract('ProxyAdmin')
  console.log("ProxyAdmin", proxyAdmin.address);

  const tpuProxy = await ethers.getContract('TransparentUpgradeableProxy')

  console.log("TransparentUpgradeableProxy address:", tpuProxy.address);

  const tx = await proxyAdmin.upgrade(tpuProxy.address, relayer.address)
  console.log("txHash:", tx.hash);
  const receipt = await tx.wait();
  console.log('rec status:', receipt.status);
}

module.exports.tags = ['RelayerUpgrade']
