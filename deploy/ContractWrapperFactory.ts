import { DeployDataStore } from "./DataStore";
// @ts-ignore
import { HardhatDefenderUpgrades } from "@openzeppelin/hardhat-defender";
import { UpgradeProxyOptions } from "@openzeppelin/hardhat-upgrades/src/utils";
import { Contract } from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";

require("@openzeppelin/hardhat-upgrades");

interface ContractWrapperFactoryOptions {
  isForceDeploy?: boolean;
}

export class ContractWrapperFactory {
  isForceDeploy: boolean;

  constructor(
    readonly db: DeployDataStore,
    readonly hre: HardhatRuntimeEnvironment,
    options: ContractWrapperFactoryOptions = {}
  ) {
    this.isForceDeploy = options.isForceDeploy || false;
  }

  async getAddressByKey(key: string) {
    return this.db.findAddressByKey(key);
  }

  async getDeployedContract<T>(
    contractId: string,
    contractName?: string
  ): Promise<T> {
    if (!contractName) {
      contractName = contractId;
    }
    const address = await this.db.findAddressByKey(contractId);
    console.log(`ID: ${contractId} Address: ${address}`);
    if (!address) throw new Error(`Contract ${contractId} not found`);
    const contract = await this.hre.ethers.getContractFactory(contractName);
    return contract.attach(address) as T;
  }

  async forceImport(contractName: string) {
    const address = await this.db.findAddressByKey(contractName);
    const contract = await this.hre.ethers.getContractFactory(contractName);

    if (address != null) {
      await this.hre.upgrades.forceImport(address, contract);
    }
  }

  async _deployOrUpgradeContract(contractName: string, args: any[]) {
    const factory = await this.hre.ethers.getContractFactory(contractName);
    const contractAddress = await this.db.findAddressByKey(contractName);
    const opts: UpgradeProxyOptions = {
      unsafeAllow: ["delegatecall"],
    };
    if (contractAddress) {
      console.log(
        `Found contract. Upgrade ${contractName}, address: ${contractAddress}`
      );
      const upgraded = await this.hre.upgrades.upgradeProxy(
        contractAddress,
        factory,
        opts
      );
      console.log(`Starting verify upgrade ${contractName}`);
      await this.verifyImplContract(upgraded);
      console.log(`Upgrade ${contractName}`);
    } else {
      const instance = await this.hre.upgrades.deployProxy(factory, args, opts);
      console.log(`wait for deploy ${contractName}`);
      // await instance.waitForDeployment();
      // await this.verifyImplContract(instance);
      const address = await instance.getAddress();
      console.log(`Address ${contractName}: ${address}`);
      await this.db.saveAddressByKey(contractName, address);
      await this.verifyProxy(address, args);
    }
  }

  async deployNonUpgradeableContract<T extends Contract>(
    contractName: string,
    args: any[] = [],
    options: {
      contractId?: string;
    } = {}
  ): Promise<T> {
    const contractId = options.contractId || contractName;
    if (!this.isForceDeploy) {
      // check for contract exists
      // if exists, return the address
      const savedAddress = await this.db.findAddressByKey(contractId);
      if (savedAddress) {
        console.log(
          `Contract ${contractId} already deployed at ${savedAddress}`
        );
        console.log("Tips: use --force to force deploy");
        const contractIns = await this.hre.ethers.getContractAt(
          contractName,
          savedAddress
        );
        return contractIns as T;
      }
    }
    console.log(`Start deploying contract ${contractId}... with args:`, args);
    const contract = await this.hre.ethers.getContractFactory(contractName);
    const contractIns = await contract.deploy(...args);
    await contractIns.waitForDeployment();
    const addressContract = await contractIns.getAddress();
    try {
      // @ts-ignore
      await this.verifyContract(this.hre, addressContract, args);
    } catch (err) {
      console.error(`-- verify contract error, skipping...`, err);
    }
    console.log(`Contract ${contractName} deployed at:`, addressContract);
    await this.db.saveAddressByKey(contractId, addressContract);
    return contractIns as T;
  }

  async verifyImplContract(upgraded: Contract) {
    const deployTransaction = JSON.stringify(upgraded);
    const jsonData = JSON.parse(deployTransaction);
    const data = jsonData["deployTransaction"]["data"];
    const decodedData = this.hre.ethers.AbiCoder.defaultAbiCoder().decode(
      ["address", "address"],
      this.hre.ethers.dataSlice(this.hre.ethers.hexlify(data), 4)
    );
    const implContractAddress = decodedData[1];
    const isVerified = await this.db.findAddressByKey(
      `${implContractAddress}:verified`
    );
    if (isVerified) return console.log(`Implement contract already verified`);
    console.log("Upgraded to impl contract", implContractAddress);
    try {
      await this.verifyContract(this.hre, implContractAddress);
      await this.db.saveAddressByKey(`${implContractAddress}:verified`, "yes");
    } catch (err) {
      if (err.message == "Contract source code already verified") {
        await this.db.saveAddressByKey(
          `${implContractAddress}:verified`,
          "yes"
        );
      }
      console.error(`-- verify contract error`, err);
    }
  }

  async verifyContract(hre, address, args = undefined, contract = undefined) {
    const verifyObj = { address } as any;
    if (args) {
      verifyObj.constructorArguments = args;
    }
    if (contract) {
      verifyObj.contract = contract;
    }
    return hre
      .run("verify:verify", verifyObj)
      .then(() => console.log("Contract address verified:", address))
      .catch((err) => {
        console.log(`Verify Error`, err);
      });
  }

  async verifyProxy(proxyAddress: string, args: any[]) {
    // // Ref: https://docs.openzeppelin.com/upgrades-plugins/1.x/api-hardhat-upgrades#verify
    return this.hre
      .run("verify", {
        address: proxyAddress,
        constructorArguments: args,
      })
      .catch((e) => {
        console.error(`Verify ${proxyAddress} Error`, e);
      });
  }
}
