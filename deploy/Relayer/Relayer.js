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


  const proxyAdmin = await deploy('ProxyAdmin', {
    from: deployer.address,
    args: [],
    log: true,
  })

  console.log("ProxyAdmin", proxyAdmin.address);

  // for test purpose
  const minStakeAmount = ethers.utils.parseEther(`100`);

  const relayerContract = await ethers.getContractAt(relayer.abi, relayer.address);
  const data = relayerContract.interface.encodeFunctionData('initialize',[minStakeAmount]);
  console.log("data",data);

  let tpuProxy = await deploy('TransparentUpgradeableProxy', {
    from: deployer.address,
    args: [relayer.address,proxyAdmin.address,data],
    log: true,
  })

  console.log("TransparentUpgradeableProxy address:", tpuProxy.address);
}

module.exports.tags = ['Relayer']
