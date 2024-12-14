import { MigrationDefinition } from "../types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const migrations: MigrationDefinition = {
  getTasks: (context) => ({
    "deploy-distributor": async () => {
      await context.factory.deployNonUpgradeableContract("Distributor", [
        1735689600,
        "0x2eAf707440974deba88F5b2425caDcc4821aA954",
        "0x7778D2470c3ee61d99a84a7503E77cbD40278F9A",
      ]);
    },

    "deploy-azToken": async () => {
      await context.factory.deployNonUpgradeableContract("AZCoiner", ["0x7778D2470c3ee61d99a84a7503E77cbD40278F9A"]);
    },

    "deploy-treasury": async () => {
      await context.factory.deployNonUpgradeableContract("Treasury", []);
    },

    "deploy-template": async () => {
      await context.factory.deployNonUpgradeableContract("VestingWalletBase", ["VestingWalletBaseTemp","0x171D39438076afD9aB1ce6f618866e375e884995",1,0,0,0,0,"0x171D39438076afD9aB1ce6f618866e375e884995"]);
    },
  }),
};

function toWei(hre: HardhatRuntimeEnvironment, value: number | string) {
  return hre.ethers.parseEther(value.toString()).toString();
}

export default migrations;
