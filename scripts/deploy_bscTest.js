require("@nomiclabs/hardhat-ethers");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log(
        "Deploying contracts with the account:",
        await deployer.getAddress()
    );
    console.log("Account balance:", (await deployer.getBalance()).toString());

    const Token = await ethers.getContractFactory("Token");
    const mToken = await Token.deploy(deployer.getAddress());
    await mToken.deployed();
    console.log("Token address:", mToken.address);

    const TokenRegister = await ethers.getContractFactory("TokenRegister");
    const mTokenRegister = await TokenRegister.deploy();
    await mTokenRegister.deployed();
    console.log("TokenRegister address:", mTokenRegister.address);

    const Router = await ethers.getContractFactory("Router");
    const mRouter = await Router.deploy(mTokenRegister.address);
    await mRouter.deployed();
    console.log("Router address:", mRouter.address);

    await  mToken.approve(mRouter.address,"1000000000000000000000000000000")
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });