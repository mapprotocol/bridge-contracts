async function main() {

    const [deployer] = await ethers.getSigners();

    console.log(
        "Deploying contracts with the account:",
        await deployer.getAddress()
    );

    console.log("Account balance:", (await deployer.getBalance()).toString());

    const Token = await ethers.getContractFactory("Token2");
    const token = await Token.deploy("0x65A0b9c37813cc5bDD18042aa7463Bcb8F4412Cf");

    // await token.deployed();

    console.log("Token address:", token.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });