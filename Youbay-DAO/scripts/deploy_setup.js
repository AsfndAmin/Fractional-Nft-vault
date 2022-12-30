
//const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
    const [executor, proposer, voter1, voter2, voter3, voter4, voter5] = await hre.ethers.getSigners();
   
 //deploy the token contract
    const GovernanceToken = await hre.ethers.getContractFactory("GovernanceToken");
    const gt = await GovernanceToken.deploy();
    await gt.deployed();
    const amount = 1000000000000000;
    await gt.transfer(voter1.address, amount);
    await gt.transfer(voter2.address, amount);
    await gt.transfer(voter3.address, amount);
    await gt.transfer(voter4.address, amount);
    await gt.transfer(voter5.address, amount);
    const balance1 = await gt.balanceOf(voter1.address);
    console.log("balance of voter1:", balance1);

    //Delegate votes from the sender to delegatee.
   // it requires users to delegate to themselves in order to activate checkpoints and have their voting power tracked.
   await gt.delegate(voter1.address);
   await gt.delegate(voter2.address);
   await gt.delegate(voter3.address);
   await gt.delegate(voter4.address);
   await gt.delegate(voter5.address);
   const votes = await gt.getVotes(voter5.address);
   console.log("return value if voter 1 is delegated:", votes);


    


 // Deploy timelock
  const minDelay = 1 // How long do we have to wait until we can execute after a passed proposal
  const TimeLock = await hre.ethers.getContractFactory("TimeLock");
  const tl = await TimeLock.deploy(minDelay, [proposer.address], [executor.address], "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
  await tl.deployed();


 
 //deploy the governence contract
 const MyGovernor = await hre.ethers.getContractFactory("MyGovernor");
 const governor = await MyGovernor.deploy(gt.address, tl.address);
 await governor.deployed();


  //deploy box contract
  const Box = await hre.ethers.getContractFactory("Box");
  const box = await Box.deploy();
  await box.deployed();
  const boxOwner = await box.owner();
  console.log("owner of box:", boxOwner);
 await box.transferOwnership(governor.address);
 const newBoxOwner = await box.owner();
 console.log("new owner of box:", newBoxOwner);


 // deploy Tresury contract
  const Treasury = await hre.ethers.getContractFactory("Treasury");
  const tres = await Treasury.deploy(executor.address);
  await tres.deployed();
  const owner = await tres.owner();
  console.log("owner of tresury:", owner);
 await tres.transferOwnership(governor.address);
 const newOwner = await tres.owner();
 console.log("new owner of tresury:", newOwner);




  // Assign roles
  const proposerRole = await tl.PROPOSER_ROLE()
  const executorRole = await tl.EXECUTOR_ROLE()

  await tl.grantRole(proposerRole, governor.address);
  await tl.grantRole(executorRole, governor.address);

//call the propose function
const encodedFunction = await box.contract.methods.store(300).encodeABI();
const description = "Store value in box";
const tx = await governance.propose([box.address], [300], [encodedFunction], description, { from: proposer });





  console.log("governor deployed to:", governor.address);

  console.log("TimeLock deployed to:", tl.address);

  console.log("Governance Token deployed to:", gt.address);

  console.log("box deployed to:", box.address);

  console.log("tresuery deployed to:", tres.address);




console.log("accounts:", executor.address);
console.log("accounts:", proposer.address);
console.log("accounts:", voter1.address);
console.log("accounts:", voter2.address);
console.log("accounts:", voter3.address);
console.log("accounts:", voter4.address);
console.log("accounts:", voter5.address);



}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
