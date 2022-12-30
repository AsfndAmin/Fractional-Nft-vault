
const hre = require("hardhat");

async function main() {

  const Box = await hre.ethers.getContractFactory("Box");
  const box = await Box.deploy();

  await box.deployed();

  console.log("box deployed to:", box.address);
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
