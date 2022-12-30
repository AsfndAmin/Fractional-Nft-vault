
const hre = require("hardhat");

async function main() {

  const yourToken = await hre.ethers.getContractFactory("yourToken");
  const token = await yourToken.deploy();

  await token.deployed();

  console.log("robotBoy deployed to:", token.address);
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
