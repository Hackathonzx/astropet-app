require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ethers");
require("dotenv").config();

const { FLOW_URL, PRIVATE_KEY } = process.env


module.exports = {
  solidity: "0.8.1",
  networks: {
    EVMOnFlowTestnet: {
      url: process.env.FLOW_URL,
      chainId: 545,
      accounts: [process.env.PRIVATE_KEY],
   },
 },

 sourcify: {
  enabled: false,
},

etherscan: {
  //apiKey: "4CZFJHHXHR9WRAA9J6TWCT4KBWT2NC5W1E", // Leave empty or remove this section
  customChains: [
    {
      network: "EVMOnFlowTestnet",
      chainId: 545,
      urls: {
        apiURL: "https://eth-sepolia.blockscout.com",
        browserURL: "https://eth-sepolia.blockscout.com/api",
      },
    },
  ],
},
}

