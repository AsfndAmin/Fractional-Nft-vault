
const hre = require("hardhat");

async function main() {

  const MyGovernor = await hre.ethers.getContractFactory("MyGovernor");
  const governor = await MyGovernor.deploy("0xBcd4042DE499D14e55001CcbB24a551F3b954096", "0xBcd4042DE499D14e55001CcbB24a551F3b954096");

  await governor.deployed();

  console.log("governor deployed to:", governor.address);
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
