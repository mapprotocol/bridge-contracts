async function main() {

    const [deployer] = await ethers.getSigners();

    console.log(
        "Deploying contracts with the account:",
        await deployer.getAddress()
    );

    const MAPBridgeV1 = await ethers.getContractFactory("MAPBridgeRelayV1");
    const mMAPBridgeV1 = await MAPBridgeV1.deploy();
    await mMAPBridgeV1.deployed();

    console.log("MAPBridgeRelayV1 address:", mMAPBridgeV1.address);



    const ProxyAdmin = await ethers.getContractFactory("ProxyAdminImport");
    const mProxyAdmin = await ProxyAdmin.deploy();
    await mProxyAdmin.deployed();

    console.log("ProxyAdmin address:", mProxyAdmin.address);

// initialize(0x3CDF7A63f514092b42FFA697aC01D81d37A2F34d,0x0000000000000000000000000000000000000000);
    const data = await mProxyAdmin.getInitCallData("0x13cb04d4a5dfb6398fc5ab005a6c84337256ee23","0x0000000000000000000000000000000000000000");

    console.log("data:", data);


    const TransparentUpgradeableProxy = await ethers.getContractFactory("TransparentUpgradeableProxy");
    const mTransparentUpgradeableProxy = await TransparentUpgradeableProxy.deploy(mMAPBridgeV1.address,mProxyAdmin.address,data);
    await mTransparentUpgradeableProxy.deployed();

    console.log("TransparentUpgradeableProxy address:", mTransparentUpgradeableProxy.address);

}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });