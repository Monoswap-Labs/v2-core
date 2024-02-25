import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import * as dotenv from 'dotenv';
dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: '0.5.16',
    settings: {
      optimizer: {
        enabled: true,
        runs: 1,
      },
    },
  },
  networks: {
    ganache: {
      url: 'http://localhost:8545',
      gasPrice: 20000000000,
      accounts: [process.env.GANACHE_PRIVATE_KEY || ''],
    },
    testnet: {
      url: 'https://data-seed-prebsc-2-s1.binance.org:8545/',
      chainId: 97,
      gasPrice: 5000000000,
      accounts: [process.env.BNB_TESTNET_PRIVATE_KEY || ''],
    },
    scrollTestnet: {
      url: 'https://sepolia-rpc.scroll.io/',
      chainId: 534351,
      accounts: [process.env.SCROLL_TESTNET_PRIVATE_KEY || ''],
      gasPrice: 1100000000, // 1.1 gwei
    },
    // for mainnet
    blastMainnet: {
      url: 'coming end of February',
      accounts: [process.env.BLAST_MAINNET_PRIVATE_KEY || ''],
      gasPrice: 1000000000,
    },
    // for Sepolia testnet
    blastSepolia: {
      url: 'https://sepolia.blast.io',
      accounts: [process.env.BLAST_SEPOLIA_PRIVATE_KEY || ''],
      gasPrice: 3000000000,
    },
  },
  etherscan: {
    apiKey: {
      scrollTestnet: 'I54U798A8ZAHR2MSRK6QX9H5QAFYWX2K6F',
      scroll: 'I54U798A8ZAHR2MSRK6QX9H5QAFYWX2K6F',
      blastSepolia: 'your API key',
    },
    customChains: [
      {
        network: 'scrollTestnet',
        chainId: 534351,
        urls: {
          apiURL: 'https://api-sepolia.scrollscan.com/api',
          browserURL: 'https://sepolia.scrollscan.com/',
        },
      },
      {
        network: 'scroll',
        chainId: 534352,
        urls: {
          apiURL: 'https://api.scrollscan.com/api',
          browserURL: 'https://scrollscan.com/',
        },
      },
      {
        network: 'blastSepolia',
        chainId: 168587773,
        urls: {
          apiURL:
            'https://api.routescan.io/v2/network/testnet/evm/168587773/etherscan',
          browserURL: 'https://testnet.blastscan.io',
        },
      },
    ],
  },
  sourcify: {
    enabled: true,
  },
};

export default config;
