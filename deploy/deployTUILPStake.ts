import { deployContract } from "./utils";

// An example of a basic deploy script
// It will deploy a Greeter contract to selected network
// as well as verify it on Block Explorer if possible for the network
export default async function () {
  const contractArtifactName = "TUILPStake";
  // const treasuryAddress = '0xA1f2592E96C282C2d5bFCF4908b36510C9Ab6DE5'
  await deployContract(contractArtifactName);
}
