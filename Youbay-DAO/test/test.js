const { expect } = require("chai");
//const { ethers } = require('hardhat');


describe("TokenVesting", function () {

  beforeEach(async function () {
    [owner, addr1, addr2, addr3, feeAddress] = await ethers.getSigners();

    decimal = 6;
    startTime = 0;
    endTime = 1658292511;
    amount =  10000;
    tokenFee = 1000;
    freeLockingFee = 1000000000;
    //feeReciever = feeAddress.address;

        //Vesting contrcat
        const TokenVesting = await ethers.getContractFactory("TokenVesting");
        vesting = await TokenVesting.deploy(owner.address);
    
        //ERC20 contract
        yourToken = await ethers.getContractFactory("yourToken"); 
        ERC20 = await yourToken.deploy();   
    
    });

describe("Deployment", function () {

    it("check the owner of the contract", async function () {
      expect(await vesting.owner()).to.equal(owner.address);
    });
 });


  describe("check name, decimal and symbol of the ERC20", function(){

    it("should confirm the name of the contract", async function(){
      expect(await ERC20.name()).to.equal("USDTDOLLAR");
    });
  
    it("should confirm the symbol of the token", async function(){
      expect(await ERC20.symbol()).to.equal("USDT");
    });

      it("should confirm the decimal of the token", async function(){
        expect(await ERC20.decimals()).to.equal(decimal);
    });
  });

  
describe("lock tokens", function(){

  it("should mint 10000 tokens and then lock them in the vesting contract", async function(){

    await ERC20.connect(addr1).mint(amount);
    await ERC20.connect(addr1).approve(vesting.address,amount);
    const lockTx = await vesting.connect(addr1).lock(ERC20.address,[[addr1.address, amount, startTime, endTime]]);
   const tx = await lockTx.wait();
    // await network.provider.send('evm_mine');
    const lockId = await (tx.events.find((e) => e.event == 'onLock').args.lockID);
    expect (lockId).to.equal(0);
    console.log("Lock created and id is: ",lockId);
    expect (await ERC20.balanceOf(vesting.address)).to.equal(amount);
  });


 it("should mint 10000 tokens and then create 2 locks and check lock ids", async function(){

  await ERC20.connect(addr1).mint(amount);
  await ERC20.connect(addr1).approve(vesting.address,amount);
  await vesting.connect(addr1).lock(ERC20.address,[[addr1.address, amount, startTime, endTime]]);
  lock = await vesting.LOCKS(0);
  console.log(lock);
  expect (await ERC20.balanceOf(vesting.address)).to.equal(10000);
  await ERC20.connect(addr1).mint(amount);
  await ERC20.connect(addr1).approve(vesting.address,5000);
  await vesting.connect(addr1).lock(ERC20.address,[[addr1.address, 5000, startTime, endTime]]);
  lock1 = await vesting.LOCKS(1);
  console.log(lock1);
});
});



describe("Free Lock", function(){

  it("should pay free locking fee then lock the tokens", async function(){
    await vesting.setFees(tokenFee,freeLockingFee,feeAddress.address,feeAddress.address);
    fees = await vesting.FEES();
    console.log(fees);

    await ERC20.connect(addr1).mint(amount);
    await ERC20.connect(addr1).approve(vesting.address,amount);
    await vesting.connect(addr1).payForFreeTokenLocks(ERC20.address,{
      value : freeLockingFee,
    })
    await vesting.connect(addr1).lock(ERC20.address,[[addr1.address, amount, startTime, endTime]]);
   expect (await ERC20.balanceOf(vesting.address)).to.equal(amount);
   lock = await vesting.LOCKS(0);
   console.log(lock);


  });
});


//   describe("whitelisted Mint", function(){

//     it("should check whitelist minting and addr1 should be whitelisted and should provide merkle proof to mint 5 nft in pre sale", async function(){
//       await vesting.setWhitelistMerkleRoot("0xdecb3cdd5b43dd51cee39ab05ef21df5b15b30c1aa1ab1bc86c658ccd166bb7f");
//       vesting.whitelistMint( 5, ["0xc23d89d4ba0f8b56a459710de4b44820d73e93736cfc0667f35cdd5142b70f0d"]);
//       expect(await vesting.balanceOf(owner.address)).to.equal(0);
//       await vesting.connect(addr1).whitelistMint(5 ,[
//         "0x999bf57501565dbd2fdcea36efa2b9aef8340a8901e3459f4a4c926275d36cdb",
//         "0xda2a605bdf59a3b18e24cd0b2d9110b6ffa2340f6f67bc48214ac70e49d12770",
//         "0xc23d89d4ba0f8b56a459710de4b44820d73e93736cfc0667f35cdd5142b70f0d"
//       ]);
//       expect (await vesting.balanceOf(addr1.address)).to.equal(5);
//     });

//     it("when set mint toggle is true whitelist Mint should not work", async function(){
//       await vesting.setMintToggle();
//       await vesting.setWhitelistMerkleRoot("0xdecb3cdd5b43dd51cee39ab05ef21df5b15b30c1aa1ab1bc86c658ccd166bb7f");
//       vesting.connect(addr1).whitelistMint(5 ,[
//         "0x999bf57501565dbd2fdcea36efa2b9aef8340a8901e3459f4a4c926275d36cdb",
//         "0xda2a605bdf59a3b18e24cd0b2d9110b6ffa2340f6f67bc48214ac70e49d12770",
//         "0xc23d89d4ba0f8b56a459710de4b44820d73e93736cfc0667f35cdd5142b70f0d"
//       ]);
//     });
// });

  
//   describe("set token uri and then check if its working ", function(){

//     it("should set token uri to www.owlDapp.com/ and then should mint a nft and check", async function(){
//       await vesting.setMintToggle();
//       await vesting.publicMint(1);
//       expect(await vesting.setBaseUri("www.owlDapp.com/"));
//       expect(await vesting.tokenURI(1)).to.equal("www.owlDapp.com/1");
//     });
// });


// describe("Approval and Transfer from", function () {

//   it("addr1 will get approval and transfer nft from owner to addr2 and check addr2 balance", async function () {
//     await vesting.setMintToggle();
//     await vesting.publicMint(2);
//     expect(await vesting.balanceOf(owner.address)).to.equal(2);
//     expect(await vesting.approve(addr1.address, 1));
//     expect(await vesting.connect(addr1).transferFrom(owner.address, addr2.address, 1));
//     expect(await vesting.balanceOf(addr2.address)).to.equal(1);
//     expect(await vesting.balanceOf(owner.address)).to.equal(1);
//     });
//   }); 


//   describe("Minting of Nfts", function(){

//     it("should mint 10 nfts to the owners account and check its balance", async function(){
//       await vesting.setMintToggle();
//       await vesting.publicMint(10);
//       expect(await vesting.balanceOf(owner.address)).to.equal(10);
//     });
  
//     it("should transfer 1 nfts to the addr2 account and check its balance", async function(){
//       await vesting.setMintToggle();
//       await vesting.publicMint(2);
//       expect(await vesting.transferFrom(owner.address, addr1.address, 1));
//       expect(await vesting.balanceOf(addr1.address)).to.equal(1);
//     });
//   });
  

//   describe("setMintingFee", function(){

//     it("should set mint price and check the mintPrice function", async function(){
//        await vesting.setMintingFee(1000);
//        expect(await vesting._mintFee()).to.equal(1000);
//        await vesting.setMintToggle();
//     });

//     it("should set mint price and mint some nfts by sending eth to the contract", async function(){
//       await vesting.setMintingFee(1000);
//       expect(await vesting._mintFee()).to.equal(1000);
//       await  vesting.setMintToggle();
//       await vesting.publicMint(1, {
//         value: ethers.utils.parseEther("0.000000000000001")
//     });
//     expect(await vesting.balanceOf(owner.address)).to.equal(1);
//    });

//    it("should set mint fee and check the whitelist mint", async function(){      
//     await vesting.setWhitelistMerkleRoot("0xdecb3cdd5b43dd51cee39ab05ef21df5b15b30c1aa1ab1bc86c658ccd166bb7f");
//     expect(await vesting.balanceOf(addr1.address)).to.equal(0);
//     await vesting.setMintingFee(1000);
//     expect(await vesting._mintFee()).to.equal(1000);

//     await vesting.connect(addr1).whitelistMint(5 ,[
//       "0x999bf57501565dbd2fdcea36efa2b9aef8340a8901e3459f4a4c926275d36cdb",
//       "0xda2a605bdf59a3b18e24cd0b2d9110b6ffa2340f6f67bc48214ac70e49d12770",
//       "0xc23d89d4ba0f8b56a459710de4b44820d73e93736cfc0667f35cdd5142b70f0d"
//     ], {
//       value: ethers.utils.parseEther("0.000000000000005")
//   });
//     expect (await vesting.balanceOf(addr1.address)).to.equal(5);

//   });  
});