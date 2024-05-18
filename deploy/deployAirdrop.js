// This is a script for deploying your contracts. You can adapt it to deploy
// yours, or create new ones.
async function main() {

  const [deployer] = await ethers.getSigners();
  const deployerAddress = await deployer.getAddress()

  console.log(
    "Deploying the Airdrop contracts with the account:",
    deployerAddress
  );

  const balance = await ethers.provider.getBalance(deployerAddress);
  console.log("Account balance:", balance);

  const nft = await ethers.deployContract("AirdropNFT");
  const token = await ethers.deployContract("AirdropToken");
  saveFrontendFiles(nft, "AirdropNFT")
  saveFrontendFiles(token, "AirdropToken")

  console.log("nft address:", await nft.getAddress());
  console.log("token address:", await token.getAddress());
}

async function saveFrontendFiles(contract, contractName) {
  const fs = require("fs");

  const contractsDir = __dirname + '/../cache/' + contractName

  fs.writeFileSync(
    contractsDir + '/address.json',
    JSON.stringify(
      {
        contract: contractName,
        address: await contract.getAddress(),
      },
      null,
      2,
    ),
  )

  const tokenArtifact = artifacts.readArtifactSync(contractName)
  fs.writeFileSync(
    contractsDir + '/artifact.json',
    JSON.stringify(tokenArtifact, null, 2),
  )
  fs.writeFileSync(
    contractsDir + '/ ' + contractName + '.abi',
    JSON.stringify(tokenArtifact.abi, null, 2),
  )
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });