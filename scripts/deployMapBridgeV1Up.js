async function main() {

    const [deployer] = await ethers.getSigners();

    console.log(
        "Deploying contracts with the account:",
        await deployer.getAddress()
    );

    const MAPBridgeV1 = await ethers.getContractFactory("MAPBridgeV1");
    const mMAPBridgeV1 = await MAPBridgeV1.deploy();
    await mMAPBridgeV1.deployed();

    console.log("MAPBridgeV1 address:", mMAPBridgeV1.address);



    const ProxyAdmin = await ethers.getContractFactory("ProxyAdminImport");
    const mProxyAdmin = await ProxyAdmin.deploy();
    await mProxyAdmin.deployed();

    console.log("ProxyAdmin address:", mProxyAdmin.address);


    const data = await mProxyAdmin.getInitCallData("0xc504210d66935fe6c066911ed1ffdef404b4ae0e","0x9E976F211daea0D652912AB99b0Dc21a7fD728e4");

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