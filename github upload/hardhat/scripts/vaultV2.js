// final to upgrade vault proxy
//

const { ethers, upgrades } = require("hardhat");
const a = 50;
const b = "0xeA29891b492Bd2bb13ab2a57C35650762D2d38e4";
const c = 8888;
const d = 4;
const PROXY = "0x7Dacb782D6CE2B7000435ccf77FA1e61D4c7E9F0";//add proxy address
async function main() {
  const FractionalNftVaultV3 = await ethers.getContractFactory("FractionalNftVaultV3");
  const vaultV3 = await upgrades.upgradeProxy(PROXY , FractionalNftVaultV3 );
  console.log("VAULT upgraded",vaultV3.address);
  
}

main();
//https://rinkeby.etherscan.io/address/0x7Dacb782D6CE2B7000435ccf77FA1e61D4c7E9F0#readProxyContract
// const vaultV3 = await upgrades.upgradeProxy(PROXY , FractionalNftVaultV3, [a,b,c,d] ); WITH THIS