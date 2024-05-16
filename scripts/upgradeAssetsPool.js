
async function main() {

  const [deployer] = await ethers.getSigners();
  const deployerAddress = await deployer.getAddress()
  console.log(
    "Upgrade AssetsPool contracts with the account:",
    deployerAddress
  );

  const balance = await ethers.provider.getBalance(deployerAddress);

  console.log("Account balance:", balance);

  const contractName = "AssetsPool";

  const contractFactory = await ethers.getContractFactory(contractName)
  const contract = await upgrades.upgradeProxy("0x",
    contractFactory
  )

  console.log("Contract address:", await contract.getAddress());

  saveFrontendFiles(contract, contractName);
  const operator = ethers.getAddress('0x')
  console.log("deploy is operator:", await contract.operators(deployer));
  console.log("operator is operator:", await contract.operators(operator));

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
    contractsDir + '/' + contractName + '.abi',
    JSON.stringify(tokenArtifact.abi, null, 2),
  )
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });