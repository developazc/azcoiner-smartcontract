import { ContractWrapperFactory } from "./ContractWrapperFactory";
import { DeployDataStore } from "./DataStore";
import { HardhatRuntimeEnvironment } from "hardhat/types";

export type MigrationTask = () => Promise<void>;

export interface MigrationDefinition {
  configPath?: string
  getTasks: (context: MigrationContext) => {
    [taskName: string]: MigrationTask
  }
}

export type Stage = "testnet";

export interface MigrationContext {
  stage: Stage
  factory: ContractWrapperFactory
  db: DeployDataStore
  hre: HardhatRuntimeEnvironment
}
