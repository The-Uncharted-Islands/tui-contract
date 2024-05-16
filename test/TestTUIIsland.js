
const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");

// const { helpers } = require('@nomicfoundation/hardhat-network-helpers');
const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("UnchartedLandsXSpirits contract", () => {
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

    beforeEach(async () => {
        [owner, alice, bob] = await ethers.getSigners();
        // initialSupply = ethers.utils.parseEther("10000");
        //   airdropFactory = await ethers.getContractFactory("USDTAirdrop");
        //   airdropContract = await airdropFactory.deploy();
        factory = await ethers.getContractFactory("TheUnchartedIslands");
        contract = await factory.deploy();

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


            // const messageHash = ethers.solidityPackedKeccak256(
            //     ['address', 'address', 'uint256', 'uint256'],
            //     [ownerAddress, userAddress, 1, 421614]);
            // console.log('message: ' + messageHash);

            // const ethSignedMessageHash = ethers.solidityPackedKeccak256(
            //     ['string', 'bytes32'],
            //     ['\x19Ethereum Signed Message:\n32', messageHash]);
            // console.log('message: ' + ethSignedMessageHash);
        });

        it("maxMintSupply", async () => {
            await contract.setMaxMintSupply(999);
            const maxMintSupply = await contract.maxMintSupply();
            console.log('maxMintSupply is ' + maxMintSupply)
            // expect(maxTotalSupply).to.equal(999);
            // const getMintableCount = await contract.getMintableCount();

            // expect(getMintableCount).to.equal(999);

        });


        it("setTokenURI", async () => {
            await contract.setTokenURI("123");
            const uri = await contract.baseTokenURI();
            console.log('uri ' + uri)
            expect(uri).to.equal("123");
        });


        // describe("mint", () => {

        //     it("mint", async () => {
        //         let hasMinted = await contract.hasMintedToday();
        //         console.log('hasMinted ' + hasMinted)

        //         await contract.connect(owner).mint();
        //         let bal = await contract.balanceOf(ownerAddress);

        //         expect(bal).to.equal(BigInt(1));
        //         await expect(
        //             contract.connect(owner).mint()).to.be.reverted;


        //         hasMinted = await contract.hasMintedToday();
        //         console.log('hasMinted ' + hasMinted)

        //         await contract.setMaxTotalSupply(999);
        //         const getMintableCount = await contract.getMintableCount();

        //         expect(getMintableCount).to.equal(998);

        //     });
    });


});
