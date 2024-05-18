
async function main() {

  const [deployer] = await ethers.getSigners();
  const deployerAddress = await deployer.getAddress()
  console.log(
    "Deploying the TUILPStake contracts with the account:",
    deployerAddress
  );

  const balance = await ethers.provider.getBalance(deployerAddress);

  console.log("Account balance:", balance);

  const contractName = "TUILPStake";

  const contractFactory = await ethers.getContractFactory(contractName)
  const contract = await upgrades.deployProxy(contractFactory, [])

  console.log("Contract address:", await contract.getAddress());

  await saveFrontendFiles(contract, contractName);

  const lpToken = ethers.getAddress('0x')
  const tuiToken = ethers.getAddress('0x')
  await contract.setToken(lpToken, tuiToken)
  console.log("lp token :", await contract.lpToken());
  console.log("tui token :", await contract.tuiToken());

}

async function saveFrontendFiles(contract, contractName) {
  const fs = require("fs");

  const contractsDir = __dirname + '/../cache/' + contractName

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

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