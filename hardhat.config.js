require("@nomiclabs/hardhat-waffle");
require('dotenv').config()
const { PRIVATE_KEY, ETH_INFURA_KEY} = process.env;


// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.0",
  networks: {
    HecoTest: {
      url: `https://http-testnet.hecochain.com`,
      chainId : 256,
      accounts: [PRIVATE_KEY]
    },
    MaticTest: {
      url: `https://rpc-mumbai.maticvigil.com/`,
      chainId : 80001,
      accounts: [PRIVATE_KEY]
    },
    Matic: {
      url: `https://rpc-mainnet.maticvigil.com`,
      chainId : 137,
      accounts: [PRIVATE_KEY]
    },
    Heco: {
      url: `https://http-mainnet-node.huobichain.com`,
      chainId : 128,
      accounts: [PRIVATE_KEY]
    },
    Eth: {
      url: `https://mainnet.infura.io/v3/` + ETH_INFURA_KEY,
      chainId : 1,
      accounts: [PRIVATE_KEY]
    },
    Ropsten: {
      url: `https://ropsten.infura.io/v3/` + INFURA_KEY,
      chainId : 3,
      accounts: [PRIVATE_KEY]
    },
    Map: {
      url: `http://159.138.90.210:7445`,
      chainId : 211,
      accounts: [PRIVATE_KEY]
    }
  }
};
