// scripts/upgrade-box.js
const { ethers, upgrades } = require("hardhat");

async function main() {
  const adminContract10 = await ethers.getContractFactory("adminContract10");
  const adminv10 = await upgrades.upgradeProxy("0xC22edCC00832Da82E52B84db913f6C8f17BC6668", adminContract10);
  console.log("admin upgraded", adminv10.address);
  
}

main();