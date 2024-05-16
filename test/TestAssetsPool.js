
const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");

// const { helpers } = require('@nomicfoundation/hardhat-network-helpers');
const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("AssetsPool contract", () => {
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
        factory = await ethers.getContractFactory("AssetsPool");
        // contract = await factory.deploy(tokenContract.getAddress(), nftContract.getAddress());
        contract = await upgrades.deployProxy(factory, [])

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

    describe("deposit withdraw token", () => {

        it("deposit withdraw", async () => {

            await contract.connect(alice).depositETH({ value: ethers.parseEther("1") });

            // amount error
            await expect(contract.connect(alice).depositETH()).
                to.be.reverted;

            // unstake
            // await contract.connect(alice).withdrawETH({ value: ethers.utils.parseEther("0.1") });
            // await expect(contract.connect(alice).withdrawETH(20)).
            //     to.be.reverted;
            // await expect(contract.connect(alice).withdrawETH(0)).
            //     to.be.reverted;
            // await expect(contract.connect(bob).withdrawETH(1)).
            //     to.be.reverted;
            // await expect(contract.connect(bob).withdrawETH(0)).
            //     to.be.reverted;

            // // await contract.connect(alice).unstake(9);
            // await expect(contract.connect(alice).withdrawETH(1)).
            //     to.be.reverted;

        });
    });

});
