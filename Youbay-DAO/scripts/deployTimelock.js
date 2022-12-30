
const hre = require("hardhat");

async function main() {

  const TimeLock = await hre.ethers.getContractFactory("TimeLock");
  const tl = await TimeLock.deploy("600", [], [], "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");

  await tl.deployed();

  console.log("TimeLock deployed to:", tl.address);
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
