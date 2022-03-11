
async function main() {

  const RelayerAddr = '0xB864eEe844698de06Dd305CBf729fDD765d9592D';

  // pre-compiled
  const EvmLiteAddr = '0x000068656164657273746F726541646472657373';

  const { mapAdmin } = await ethers.getNamedSigners()

  console.log('mapAdmin:', mapAdmin.address);

  const cAbi=[
    // setRelayer function only
    `function setRelayer(address relayer) external`,
    `function getRelayer() view returns (address relayer)`,
  ]

  const liteNode = await ethers.getContractAt(cAbi, EvmLiteAddr);

  const tx = await liteNode.connect(mapAdmin).setRelayer(RelayerAddr);
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

