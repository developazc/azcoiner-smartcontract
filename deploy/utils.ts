import {DeployDataStore} from "./DataStore";
import {Stage} from "./types";


const DATA_STORE_FILE = {
    goerli: "./deployData_eth_goerli.db",
    arbitrumOne: "./deployData_arb_mainnet.db",
    arbitrumSepolia: "./deployData_arb_sepolia.db",
};
export function loadDb(stage: Stage) {
    return new DeployDataStore(DATA_STORE_FILE[stage]);
}
