// This is a script for deploying your contracts. You can adapt it to deploy
// yours, or create new ones.
async function main() {
  // This is just a convenience check
  if (network.name === "hardhat") {
    console.warn(
      "You are trying to deploy a contract to the Hardhat Network, which" +
      "gets automatically created and destroyed every time. Use the Hardhat" +
      " option '--network localhost'"
    );
  }

  // ethers is available in the global scope
  const [deployer] = await ethers.getSigners();
  console.log(
    "Deploying the TUIStake contracts with the account:",
    await deployer.getAddress()
  );

  const contractName = "TUIStake";

  // const contract = await ethers.deployContract(contractName, [token.getAddress(), nft.getAddress()]);
  nft_address = '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512'
  token_address = '0x5FbDB2315678afecb367f032d93F642f64180aa3'
  const contract = await ethers.deployContract(contractName, [token_address, nft_address]);

  console.log(
    `Deploy stake contract ${await contract.getAddress()} `
  );

  // We also save the contract's artifacts and address in the frontend directory
  saveFrontendFiles(contract, contractName);
}

function saveFrontendFiles(contract, contractName) {

  const fs = require("fs");
  const contractsDir = __dirname + "/../cache/" + contractName;

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    contractsDir + "/address.json",
    JSON.stringify({ Token: contract.getAddress() }, undefined, 2)
  );

  const tokenArtifact = artifacts.readArtifactSync(contractName);

  fs.writeFileSync(
    contractsDir + "/artifact.json",
    JSON.stringify(tokenArtifact, null, 2)
  );

  // console.log(tokenArtifact.abi);
  fs.writeFileSync(
    contractsDir + "/" + contractName + "_abi.json",
    JSON.stringify(tokenArtifact.abi)
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });