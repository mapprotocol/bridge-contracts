require('@nomiclabs/hardhat-waffle')
require('hardhat-gas-reporter')
require('hardhat-spdx-license-identifier')
require('hardhat-deploy')
require('hardhat-abi-exporter')
require('@nomiclabs/hardhat-ethers')
require('dotenv/config')
require('@nomiclabs/hardhat-etherscan')

const { PRIVATE_KEY, ETH_INFURA_KEY, INFURA_KEY, HECO_SCAN_KEY} = process.env;


task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});


module.exports = {
  defaultNetwork: 'hardhat',
  abiExporter: {
    path: './abi',
    clear: false,
    flat: true,
  },
  namedAccounts: {
    deployer: {
      default: 0,
      1: '0x289F8F063c4304F432bb96DD31e82bdCc5CcE142',
      3: '0x289F8F063c4304F432bb96DD31e82bdCc5CcE142',
      22776: '0x289F8F063c4304F432bb96DD31e82bdCc5CcE142',
    },
    wcoin: {
      default: 0,
      1: '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2',
      3: '0xf70949bc9b52deffcda63b0d15608d601e3a7c49',
      22776: '0x13cb04d4a5dfb6398fc5ab005a6c84337256ee23',
    },
    mapcoin: {
      default: 0,
      1: '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2',
      3: '0x2020f4b99433067F4a5ED99Ce8392d94a8AC70d1',
      22776: '0x0000000000000000000000000000000000000000',
    },
    usdt: {
      default: 0,
      22776: '0x33daba9618a75a7aff103e53afe530fbacf4a3dd',
    },
    usdc: {
      default: 0,
      22776: '0x9f722b2cb30093f766221fd0d37964949ed66918',
    },
    eth: {
      default: 0,
      22776: '0x05ab928d446d8ce6761e368c8e7be03c3168a9ec',
    },
    idv: {
      default: 0,
      22776: '0xeac6cfd6e9e2fa033d85b7abdb6b14fe8aa71f2a',
    },
  },

  networks: {
    bscmain: {
      url: `https://bsc-dataseed2.defibit.io/`,
      accounts: [PRIVATE_KEY],
      chainId: 56,
      gasMultiplier: 1.5,
      gasPrice: 5.5 * 1000000000
    },
    bsctest: {
      url: `https://data-seed-prebsc-2-s3.binance.org:8545`,
      accounts: [PRIVATE_KEY],
      chainId: 97,
      gasMultiplier: 2,
      tags: ['test'],
    },
    hardhat: {
      forking: {
        enabled: true,
        url: `https://bsctest.pls2e.cc`,
        url: `https://data-seed-prebsc-1-s1.binance.org:8545`,
      },
      live: true,
      saveDeployments: false,
      tags: ['test', 'local'],
      timeout: 2000000,
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
      url: `https://poc2-rpc.maplabs.io`,
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
    },
  },
  solidity: {
    compilers: [
      {
        version: '0.8.7',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.4.22',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  spdxLicenseIdentifier: {
    overwrite: true,
    runOnCompile: true,
  },
  mocha: {
    timeout: 2000000,
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
}
