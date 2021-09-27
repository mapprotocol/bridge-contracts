async function main() {
    const [deployer] = await ethers.getSigners();
    console.log(
        "Deploying contracts with the account:",
        await deployer.getAddress()
    );
    console.log("Account balance:", (await deployer.getBalance()).toString());

    const Token = await ethers.getContractFactory("Token");
    const mToken = await Token.deploy("USDT","USDT",18);
    await mToken.deployed();
    console.log("Token address:", mToken.address);

    const MapERC20 = await ethers.getContractFactory("MapERC20");
    const mMapERC20 = await MapERC20.deploy("MapUSDT","MapUSDT",mToken.address);
    await mMapERC20.deployed();
    console.log("MapERC20 address:", mMapERC20.address);

    const TokenRegister = await ethers.getContractFactory("TokenRegister");
    const mTokenRegister = await TokenRegister.deploy();
    await mTokenRegister.deployed();
    console.log("TokenRegister address:", mTokenRegister.address);

    await mTokenRegister.regToken(3,mToken.address,mMapERC20.address,"0x0000000000000000000000000000000000000000");

    const Router = await ethers.getContractFactory("Router");
    const mRouter = await Router.deploy("0x000000000000000000747275657374616b696E67",mTokenRegister.address);
    await mRouter.deployed();
    console.log("Router address:", mRouter.address);

    await mMapERC20.setAuth(mRouter.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });