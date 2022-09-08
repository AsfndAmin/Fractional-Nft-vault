const { ethers, upgrades } = require("hardhat");

async function main() {

    const adminContractv2 = await ethers.getContractFactory("adminContractv2");
    console.log("Deploying admin...");
    const adminv2 = await adminContractv2.deploy();
    await adminv2.deployed();
    console.log("Contract deployed to:", adminv2.address);

}
main();