async function main() {

    const [deployer] = await ethers.getSigners();

    console.log(
        "Deploying contracts with the account:",
        await deployer.getAddress()
    );

    console.log("Account balance:", (await deployer.getBalance()).toString());
    //
    // const Token = await ethers.getContractFactory("Token2");
    // const token = await Token.deploy("0x289F8F063c4304F432bb96DD31e82bdCc5CcE142");
    // await token.deployed();

    // console.log("Token address:", token.address);

    const MAPBridgeV1 = await ethers.getContractFactory("MAPBridgeV1");
    const mMAPBridgeV1 = await MAPBridgeV1.deploy();
    await mMAPBridgeV1.deployed();

    console.log("MAPBridgeV1 address:", mMAPBridgeV1.address);

    mMAPBridgeV1.initialize("0xc504210d66935fe6c066911ed1ffdef404b4ae0e","0x9E976F211daea0D652912AB99b0Dc21a7fD728e4");

    // await hre.run("verify:verify", {
    //     address: mMAPBridgeV1.address
    // });

    // await mMAPBridgeV1.register(token.address,"");
    // console.log("mMAPBridgeV1 register:", "ok");
    //
    // await token.approve(mMAPBridgeV1.address,"100000000000000000000000000000");
    // console.log("token.approve:", "ok");
    //
    // await mMAPBridgeV1.transferOut(token.address,deployer.address,"10000000000000000000",10);
    // console.log("mMAPBridgeV1.transferToken:", "ok");
    //
    // await token.mint(mMAPBridgeV1.address,"10000000000000000000000000");
    // console.log("token.mint", "ok");
    //
    // await token.mint("0xCf5CB26DB9B4dC55A661DBcB0882e7cD91De1512","10000000000000000000000000");
    // console.log("token.mint xiaohan： 0xCf5CB26DB9B4dC55A661DBcB0882e7cD91De1512", "ok");
    //
    // await mMAPBridgeV1.transferIn(token.address,deployer.getAddress(),deployer.getAddress(),"10000000000000000000",
    //     "0x3ec01d2cbb2766075ca1e3baef271d8c59c8b146ce3f66e77a50b1f27558e87b",10,1);
    // console.log("mMAPBridgeV1.withdrawToken:", "ok");
    //
    // await mMAPBridgeV1.transferIn(token.address,deployer.getAddress(),deployer.getAddress(),"10000000000000000000",
    //     "0x3ec01d2cbb2766075ca1e3baef271d8c59c8b146ce3f66e77a50b1f27558e87b",10,1);
    // console.log("mMAPBridgeV1.withdrawToken:", "ok");
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });