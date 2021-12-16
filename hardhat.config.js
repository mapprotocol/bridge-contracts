require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config()
const { PRIVATE_KEY, ETH_INFURA_KEY, INFURA_KEY, HECO_SCAN_KEY} = process.env;


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
    HecoTest: {
      url: `https://http-testnet.hecochain.com`,
      chainId : 256,
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
      url: `http://13.214.151.165:7445`,
      chainId : 22776,
      accounts: [PRIVATE_KEY]
    },
    Bsc: {
      url: `https://bsc-dataseed1.binance.org/`,
      chainId : 56,
      accounts: [PRIVATE_KEY]
    },
    BscTest: {
      url: `https://data-seed-prebsc-2-s3.binance.org:8545/`,
      chainId : 97,
      accounts: [PRIVATE_KEY]
    },
    Abey: {
      url: `http://54.169.112.1:8545`,
      chainId : 179,
      accounts: [PRIVATE_KEY]
    },
    True: {
      url: `https://rpc.truescan.network/`,
      chainId : 19330,
      accounts: [PRIVATE_KEY]
    }
  },
  etherscan:{
    apiKey: "CR4UNUCE7SWTN7XFBWM5JAQ8MYSH9VEUZ7"
  }
};
