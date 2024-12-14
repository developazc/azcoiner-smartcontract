import {readdir} from "fs/promises";
import {task} from "hardhat/config";
import * as path from "path";
import {MigrationContext, Stage} from "../deploy/types";
import {ContractWrapperFactory} from "../deploy/ContractWrapperFactory";
import {loadDb} from "../deploy/utils";
import {HardhatRuntimeEnvironment} from "hardhat/types";

task('deploy', 'deploy contracts', async (taskArgs: { stage: Stage, task: string }, hre: HardhatRuntimeEnvironment) => {
  const basePath = path.join(__dirname, "../deploy/migrations")
  const filenames = await readdir(basePath)
  const db = loadDb(taskArgs.stage);
  const context: MigrationContext = {
    stage: taskArgs.stage,
    factory: new ContractWrapperFactory(db, hre),
    db,
    hre
  }

  for (const filename of filenames) {
    console.info(`Start migration: ${filename}`)
    const module = await import(path.join(basePath, filename))
    const tasks = module.default.getTasks(context)
    for (const key of Object.keys(tasks)) {
      if (!taskArgs.task || taskArgs.task == key) {
        console.group(`-- Start run task ${key}`)
        await tasks[key]()
        console.groupEnd()
      }
    }
  }
}).addParam('stage', 'Stage').addOptionalParam('task', 'Task Name');

export default {}
