
async function main() {


  const tpuProxy = await ethers.getContract('TransparentUpgradeableProxy')
  console.log("TransparentUpgradeableProxy address:", tpuProxy.address);

  // pre-compiled
  const EvmLiteAddr = '0x000068656164657273746F726541646472657373';

  const [ mapAdmin ] = await ethers.getSigners()

  console.log('mapAdmin:', mapAdmin.address);

  const cAbi=[
    // setRelayer function only
    `function setRelayer(address relayer) external`,
    `function getRelayer() view returns (address relayer)`,
  ]

  const liteNode = await ethers.getContractAt(cAbi, EvmLiteAddr);

  const tx = await liteNode.connect(mapAdmin).setRelayer(tpuProxy.address);
  console.log('tx hash:', tx.hash);

  const receipt = await tx.wait()
  console.log('rec status:', receipt.status);

  const relayerAddr = await liteNode.getRelayer();
  console.log('relayerAddr:', relayerAddr);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

