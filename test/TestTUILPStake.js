
const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");

// const { helpers } = require('@nomicfoundation/hardhat-network-helpers');
const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("TUIStake contract", () => {
    let factory;
    let contract;
    let tokenContract;
    let nftContract;
    let owner;
    let alice;
    let bob;
    let ownerAddress;
    let aliceAddress;
    let bobAddress;

    beforeEach(async () => {
        [owner, alice, bob] = await ethers.getSigners();
        // airdropFactory = await ;
        factory = await ethers.getContractFactory("AirdropToken")
        tokenContract = await factory.deploy();
        factory = await ethers.getContractFactory("TUILPStake");
        // contract = await factory.deploy(tokenContract.getAddress(), nftContract.getAddress());
        contract = await upgrades.deployProxy(factory, [])

        await contract.setLPToken(tokenContract.getAddress());

        ownerAddress = await owner.getAddress();
        aliceAddress = await alice.getAddress();
        bobAddress = await bob.getAddress();
    });

    describe("Correct setup", () => {

        it("owner should be deployer", async () => {
            const contractOwner = await contract.owner();
            console.log('owner is ' + contractOwner)
            expect(contractOwner).to.equal(ownerAddress);
        });
    });

    describe("stake token", () => {

        it("stake token", async () => {
            await tokenContract.connect(alice).mint(1000000);
            await tokenContract.connect(alice).approve(contract.getAddress(), 100000000);

            await contract.connect(alice).stake(10);

            // amount error
            await expect(contract.connect(alice).stake(0)).
                to.be.reverted;
            await expect(contract.connect(alice).stake(100100001)).
                to.be.reverted;

            // unstake
            await contract.connect(alice).unstake(10);
            await expect(contract.connect(alice).unstake(20)).
                to.be.reverted;
            await expect(contract.connect(alice).unstake(0)).
                to.be.reverted;
            await expect(contract.connect(bob).unstake(1)).
                to.be.reverted;
            await expect(contract.connect(bob).unstake(0)).
                to.be.reverted;

            // await contract.connect(alice).unstake(9);
            await expect(contract.connect(alice).unstake(1)).
                to.be.reverted;

        });
    });

});
