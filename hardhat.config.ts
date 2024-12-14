import "hardhat-contract-sizer";
import "./scripts/deploy";
import "./deploy/migrations/000-deploy";
import "@typechain/hardhat";

require("dotenv").config();

const mockingAccount =
  "0x433c50ca0be244d2fad8e0f219440cc0e279db0bffbcb09ff45a4e218f42761a";

module.exports = {
  defaultNetwork: "hardhat",

  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    hardhat: {
      allowUnlimitedContractSize: true,
    },
    bsc_testnet: {
        url: "https://bsc-testnet.blockpi.network/v1/rpc/public",
        chainId: 97,
        accounts: [process.env.PRIV_TESTNET_ACCOUNT ?? mockingAccount],
    },
    bsc_mainnet: {
      url: "https://binance.llamarpc.com",
      chainId: 56,
      accounts: [process.env.PRIV_MAINNET_ACCOUNT ?? mockingAccount],
    },
  },

  solidity: {
    compilers: [
      {
        version: "0.8.27",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  etherscan: {
    apiKey: {
     bscTestnet: "XZ7X2X7HJ3V8UDPT96FHS5YMI997SD3MUQ",
     bscMainnet: "XZ7X2X7HJ3V8UDPT96FHS5YMI997SD3MUQ",
     bsc: "XZ7X2X7HJ3V8UDPT96FHS5YMI997SD3MUQ",
    },
    customChains: [
      {
        network: "arbitrumSepolia",
        chainId: 421614,
        urls: {
          apiURL: "https://api-sepolia.arbiscan.io/api",
          browserURL: "https://sepolia.arbiscan.io/",
        },
      },
      {
        network: "baseSepolia",
        chainId: 84532,
        urls: {
          apiURL: "https://api-sepolia.basescan.org/api",
          browserURL: "https://sepolia.basescan.org/",
        },
      },
      {
        network: "baseStaging",
        chainId: 8453,
        urls: {
          apiURL: "https://api.basescan.org/api",
          browserURL: "https://basescan.org/",
        },
      },
      {
        network: "baseProd",
        chainId: 8453,
        urls: {
          apiURL: "https://api.basescan.org/api",
          browserURL: "https://basescan.org/",
        },
      },
    ],
  },
  typechain: {
    outDir: "typeChain",
    target: "ethers-v6",
  },
  contractSizer: {
    strict: true,
  },
  mocha: {
    timeout: 100000,
  },
  abiExporter: {
    path: "./abi",
    clear: true,
    spacing: 2,
    runOnCompile: true,
  },
  docgen: {
    path: "./docs",
  },
};
