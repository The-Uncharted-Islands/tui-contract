require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {

  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      forking: {
        url: "https://rpc.ankr.com/eth",
        accounts: ["0x"]
      },

    },
    arbsepolia: {
      url: '',
      accounts: [
        '0x',
      ],
    },
    ethereum: {
      url: 'https://rpc.ankr.com/eth',
      accounts: [
        '0x',
      ],
    },
  },
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },

  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 40000
  },
  etherscan: {
    apiKey: "",
  },

  sourcify: {
    enabled: true
  }
};
