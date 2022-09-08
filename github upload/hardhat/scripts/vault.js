//final working code to deploy uups with initializer arguments

const hre = require("hardhat");
const a = 20;
const b = "0xeA29891b492Bd2bb13ab2a57C35650762D2d38e4";
const c = 9999;
const d = 1;
async function main() {

  const FractionalNftVault = await hre.ethers.getContractFactory("FractionalNftVault");
 // const admin = await adminContract.deploy();
  const vault = await upgrades.deployProxy(FractionalNftVault, [a,b,c,d] ,{ kind: 'uups', initializer: "initialize"});

  await vault.deployed();

  console.log("vault deployed to:", vault.address);
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
