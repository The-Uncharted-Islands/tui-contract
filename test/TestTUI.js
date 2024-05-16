
const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");

// const { helpers } = require('@nomicfoundation/hardhat-network-helpers');
const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("TUI contract", () => {
    let airdropFactory;
    let airdropContract;
    let factory;
    let contract;
    let owner;
    let alice;
    let bob;
    let initialSupply;
    let ownerAddress;
    let aliceAddress;
    let bobAddress;
    let treasuryAddress;

    beforeEach(async () => {
        [owner, alice, bob] = await ethers.getSigners();
        treasuryAddress = await bob.getAddress();

        contract = await ethers.deployContract("TUI", [treasuryAddress]);

        ownerAddress = await owner.getAddress();
        aliceAddress = await alice.getAddress();
        bobAddress = await bob.getAddress();
        userAddress = await bob.getAddress();
    });

    describe("Correct setup", () => {

        it("owner should be deployer", async () => {
            const contractOwner = await contract.owner();
            console.log('owner is ' + contractOwner)
            expect(contractOwner).to.equal(ownerAddress);
        });

        it("treasury balance", async () => {
            let balance = await contract.balanceOf(treasuryAddress);
            console.log('balance is ' + balance)
            // expect(maxTotalSupply).to.equal(999);
            // const getMintableCount = await contract.getMintableCount();

            // expect(getMintableCount).to.equal(999);

        });



        it("black list", async () => {
            // ok
            await contract.connect(bob).transfer(aliceAddress, 1);
            let balance = await contract.balanceOf(aliceAddress);
            console.log('balance is ' + balance)

            // add black
            await contract.connect(owner).setBlackList(bobAddress, true);

            // add black fail
            let zeroAddress = ethers.getAddress("0x0000000000000000000000000000000000000000")
            await expect(contract.connect(owner).setBlackList(zeroAddress, true)).to.be.reverted;

            // fail
            await expect(contract.connect(bob).transfer(aliceAddress, 1)).to.be.reverted;
            await expect(contract.connect(alice).transfer(bobAddress, 1)).to.be.reverted;

            await contract.connect(owner).setBlackList(bobAddress, false);
            await contract.connect(bob).transfer(aliceAddress, 1)
            balance = await contract.balanceOf(aliceAddress);
            console.log('balance is ' + balance)

            await contract.connect(alice).transfer(bobAddress, 1)
            balance = await contract.balanceOf(bobAddress);
            console.log('balance is ' + balance)

        });
    });


});
