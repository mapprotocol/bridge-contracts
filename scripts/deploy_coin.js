async function main() {

    const [deployer] = await ethers.getSigners();

    console.log(
        "Deploying contracts with the account:",
        await deployer.getAddress()
    );

    console.log("Account balance:", (await deployer.getBalance()).toString());

    const Token = await ethers.getContractFactory("MapERC20NoAuth");
    const token = await Token.deploy("0x07cc6bbe1ea85a39ee3fe359750a553a906fbf4e","test","T");

    await token.deployed();
    console.log("Token address:", "mint", token.address);
    await token.mint("0xaB4D1a46F0F9331201042C359f00C81537741673","10000000000000000000000000");
    console.log("Token address:", "burn", token.address);
    await token.burn("0xaB4D1a46F0F9331201042C359f00C81537741673","10000000000000000000000000");
    console.log("Token address:", token.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });