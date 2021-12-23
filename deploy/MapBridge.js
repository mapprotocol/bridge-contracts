module.exports = async function ({ ethers, deployments }) {
    const {deploy} = deployments
    const {deployer} = await ethers.getNamedSigners()

    console.log(
        "Deploying contracts with the account:",
        await deployer.getAddress()
    );

    console.log("Account balance:", (await deployer.getBalance()).toString());


    await deploy("MAPBridgeV1",{
        from : deployer.address,
        args :[],
        log:true,
        contract: "MAPBridgeV1",
    })


    let [mMAPBridgeV1] = await ethers.getContract('MAPBridgeV1')

    console.log("MAPBridgeV1 address:", mMAPBridgeV1.address);

    mMAPBridgeV1.initialize("0xc504210d66935fe6c066911ed1ffdef404b4ae0e","0x9E976F211daea0D652912AB99b0Dc21a7fD728e4");

}

module.exports.tags = ['MapBridge']