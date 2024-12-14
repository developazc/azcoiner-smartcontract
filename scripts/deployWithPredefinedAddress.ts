import { ethers } from "hardhat";
const { keccak256 } = ethers;

function hasAnyNumberRepeatingFiveTimes(ethAddress, checkNum = 8) {
  // Regular expression to match any digit repeated consecutively five times
  const consecutiveNumberRegex = /(.)\1{6}/;

  // Process the ethereum address, starting from index 2 to skip the '0x' part
  const addressSection = ethAddress.slice(2);

  // Test the address section for a consecutive number repeated five times
  return consecutiveNumberRegex.test(addressSection);
}

async function findSaltForSuffix(suffix, deployerAddress, initCodeHash) {
  let salt = "0x0e16a7"; // Start salt

  while (true) {
    let paddedSalt = ethers.zeroPadValue(salt, 32);
    let computedAddress = ethers.getCreate2Address(
      deployerAddress,
      paddedSalt,
      initCodeHash,
    );

    console.log(`Salt: ${salt}`);
    console.log(`Contract will be deployed at: ${computedAddress}`);
    console.log("-------------------");
    if (
      computedAddress.toLowerCase().includes("99999")
      // computedAddress.toLowerCase().endsWith("2024")
      // hasAnyNumberRepeatingFiveTimes(computedAddress)
    ) {
      console.log("Found salt!");
      return paddedSalt;
    }

    salt = ethers.toBeHex((BigInt(salt) + 1n).toString());
    console.log(salt);
  }
}

async function main() {
  // deploy the Deployer contract
  // const deployer = await ethers.deployContract("Deployer");
  // await deployer.waitForDeployment();
  //
  // const deployerAddress = deployer.target;
  // console.log("Deployer address:", deployerAddress);
  const deployer = await ethers.getContractAt("Deployer", "0x4e043e62b072bdb273f84a44c500d9e2106675b4");

  const YourContractFactory = await ethers.getContractFactory("XLordsToken");
  const initCode = YourContractFactory.bytecode;

  // Assuming the bytecode is not modified by the constructor arguments or otherwise
  const initCodeHash = keccak256(initCode);

  const salt = await findSaltForSuffix(
    "999999",
    // deployerAddress,
    "0x4e043e62b072bdb273f84a44c500d9e2106675b4",
    initCodeHash,
  );
  console.log("Found salt! Deploying contract...", salt);

  await deployer.deploy(salt, initCode);
  console.log("Contract deployed!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
