// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const { network } = require("hardhat");
const { networkConfig } = require("../helper-hardhat-config");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;

  let ethUsdPriceFeedAddress;
  if(developmentChains.includes(network.name)){
    const ethUsdAggregator = await deployments.get("MockV3Aggregator");
    ethUsdPriceFeedAddress = ethUsdAggregator.address;
  }else{
    ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
  }

  const initialBalance = ethers.utils.parseEther("0.01");
  //const Weatherance = await hre.ethers.getContractFactory("Weatherance");
  const weatherance = await deploy("Weatherance", {
    from: deployer,
    args: [ethUsdPriceFeedAddress],
    value: initialBalance,
    log: true,
  });
  log("-------------------------------------------------------");

  //await weatherance.deployed();
 // console.log("Weatherance deployed to:", weatherance.address);
};

module.exports.tags = ["all", "weatherance"];
// main().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });
