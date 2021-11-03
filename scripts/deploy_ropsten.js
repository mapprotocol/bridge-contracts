async function main() {
    const [deployer] = await ethers.getSigners();
    console.log(
        "Deploying contracts with the account:",
        await deployer.getAddress()
    );
    console.log("Account balance:", (await deployer.getBalance()).toString());


    const TokenRegister = await ethers.getContractFactory("TokenRegister");
    const mTokenRegister = await TokenRegister.deploy();
    await mTokenRegister.deployed();
    console.log("TokenRegister address:", mTokenRegister.address);

    const Router = await ethers.getContractFactory("Router");
    const mRouter = await Router.deploy(mTokenRegister.address);
    await mRouter.deployed();
    console.log("Router address:", mRouter.address);

    const Token = await ethers.getContractFactory("Token");
    const mToken = await Token.deploy();
    await mToken.deployed();
    console.log("Token address:", mToken.address);


    const MapERC20 = await ethers.getContractFactory("MapERC20");
    const mMapERC20 = await MapERC20.deploy(mToken.address,mRouter.address);
    await mMapERC20.deployed();
    console.log("MapERC20 address:", mMapERC20.address);


    await mTokenRegister.regTokenSource(mToken.address,mMapERC20.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });