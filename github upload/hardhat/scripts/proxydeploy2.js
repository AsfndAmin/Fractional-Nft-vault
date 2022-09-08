// scripts/upgrade-box.js
const { ethers, upgrades } = require("hardhat");

async function main() {
const gas = await ethers.provider.getGasPrice();
  const adminContract11 = await ethers.getContractFactory("adminContract11");
  console.log("Upgrading");
   const adminv11 = await upgrades.upgradeProxy("0xC22edCC00832Da82E52B84db913f6C8f17BC6668", adminContract11, {
     gasPrice:gas,

    });
   console.log("Upgraded", adminv11.address);
}

main();
