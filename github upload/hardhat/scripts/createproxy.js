// scripts/create-box.js
const { ethers, upgrades } = require("hardhat");

async function main() {
  const adminContract = await ethers.getContractFactory("adminContract");
  const admin = await upgrades.deployProxy( adminContract);
  await admin.deployed();
  console.log("Box deployed to:", admin.address);
}

main();