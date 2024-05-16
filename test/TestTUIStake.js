
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
        factory = await ethers.getContractFactory("AirdropNFT")
        nftContract = await factory.deploy();
        factory = await ethers.getContractFactory("TUIStake");
        contract = await factory.deploy(tokenContract.getAddress(), nftContract.getAddress());

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

    describe("setStakePool", () => {

        it("setStakePool", async () => {
            await expect(contract.connect(alice).setStakePool(1, 112312, 22323, 500)).
                to.be.reverted;

            // new
            await contract.connect(owner).setStakePool(1, 112312, 22323, 500);
            let pool = await contract.connect(owner).pools(1);
            console.log(pool);
            await expect(pool[3]).to.be.equal(500);
            // update
            await contract.connect(owner).setStakePool(1, 112312, 22323, 1000);
            pool = await contract.connect(owner).pools(1);
            await expect(pool[3]).to.be.equal(1000);

            // new
            await contract.connect(owner).setStakePool(2, 112312, 22323, 9900);
            pool = await contract.connect(owner).pools(2);
            await expect(pool[3]).to.be.equal(9900);

            // check old
            pool = await contract.connect(owner).pools(1);
            await expect(pool[3]).to.be.equal(1000);

        });
    });


    describe("stake nft", () => {

        it("stake nft", async () => {
            await nftContract.connect(alice).mint();
            await nftContract.connect(alice).mint();
            await nftContract.connect(alice).mint();
            await nftContract.connect(alice).setApprovalForAll(contract.getAddress(), true);

            await expect(contract.connect(alice).stakeNFT([])).
                to.be.reverted;

            await expect(contract.connect(alice).unstakeNFT([])).
                to.be.reverted;


            await expect(contract.connect(alice).stakeNFT([1, 1, 2])).
                to.be.reverted;
            // await contract.connect(alice).stakeNFT([1, 1, 2])
            await contract.connect(alice).stakeNFT([1, 2, 3]);
            let nfts = await contract.connect(alice).getStakeNfts(aliceAddress);
            console.log(nfts)
            let nftss = await contract.connect(alice).getStakeNfts(aliceAddress);
            console.log(nftss)

            await expect(contract.connect(alice).stakeNFT([1])).
                to.be.reverted;
            await expect(contract.connect(alice).stakeNFT([1, 2, 3])).
                to.be.reverted;


            await expect(contract.connect(alice).unstakeNFT([1, 1, 3])).
                to.be.reverted;
            await expect(contract.connect(alice).unstakeNFT([])).
                to.be.reverted;
            await expect(contract.connect(alice).unstakeNFT([123])).
                to.be.reverted;
            await expect(contract.connect(bob).unstakeNFT([1])).
                to.be.reverted;

            nfts = await contract.connect(alice).getStakeNfts(aliceAddress);
            console.log(nfts)

            await contract.connect(alice).unstakeNFT([1]);
            nfts = await contract.connect(alice).getStakeNfts(aliceAddress);
            console.log(nfts)
            await contract.connect(alice).unstakeNFT([2]);
            nfts = await contract.connect(alice).getStakeNfts(aliceAddress);
            console.log(nfts)

            await contract.connect(alice).unstakeNFT([3]);
            nfts = await contract.connect(alice).getStakeNfts(aliceAddress);
            console.log(nfts)

            // await contract.connect(alice).unstakeNFT([2, 3]);
            nfts = await contract.connect(alice).getStakeNfts(aliceAddress);
            console.log(nfts)

            await expect(contract.connect(alice).unstakeNFT([1, 2, 3])).
                to.be.reverted;
            await expect(contract.connect(alice).unstakeNFT([1])).
                to.be.reverted;
            await expect(contract.connect(alice).unstakeNFT([])).
                to.be.reverted;

        });
    });

    describe("stake token", () => {

        it("stake token", async () => {
            await tokenContract.connect(alice).mint(1000000);
            await tokenContract.connect(alice).approve(contract.getAddress(), 100000000);

            await expect(contract.connect(alice).stake(1, 10)).
                to.be.reverted;


            await contract.connect(owner).setStakePool(1, 112312, 22323, 500);

            await expect(contract.connect(alice).stake(1, 10)).
                to.be.reverted;

            await contract.connect(owner).setStakePool(1, 112312, 0, 500);

            await contract.connect(alice).stake(1, 10);

            await expect(contract.connect(alice).stake(2, 10)).
                to.be.reverted;

            // amount error
            await expect(contract.connect(alice).stake(1, 0)).
                to.be.reverted;
            await expect(contract.connect(alice).stake(1, 100100001)).
                to.be.reverted;

            // unstake
            await contract.connect(alice).unstake(1);
            await expect(contract.connect(alice).unstake(2)).
                to.be.reverted;
            await expect(contract.connect(alice).unstake(1)).
                to.be.reverted;

            await contract.connect(owner).setStakePool(2, 112312, 0, 500);
            await contract.connect(alice).stake(2, 10);
            await expect(contract.connect(alice).unstake(1)).
                to.be.reverted;
            await expect(contract.connect(bob).unstake(2)).
                to.be.reverted;

            await contract.connect(alice).unstake(2);

        });
    });

});
