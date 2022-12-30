
const hre = require("hardhat");

async function main() {

  const GovernanceToken = await hre.ethers.getContractFactory("GovernanceToken");
  const gt = await GovernanceToken.deploy();

  await gt.deployed();

  console.log("gt deployed to:", gt.address);
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
