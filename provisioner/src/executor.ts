import {mkdir, readFile, writeFile} from "node:fs/promises";
import {dirname} from "node:path";
import {parseArgs} from "node:util";
import {createInterface} from "node:readline/promises";
import type {Task} from "./task.ts";
import {exists} from "./util.ts";

export const execute = async <const VarNames extends string[]>(
    varNames: VarNames,
    buildTasks: (vars: Record<VarNames[number], string>, env: {
      home: string
    }) => (Task | Promise<Task> | Promise<Task[]>)[],
) => {
  const {values: args} = parseArgs({
    args: process.argv.slice(2),
    options: {
      "dry-run": {type: "boolean", default: false},
    },
  });

  const vars = await setupVars(varNames);
  const variables = Object.entries(vars).map(([key, value]) => `${key}: ${value}`).join('\n')
  console.log(`[variables]\n${variables}`);

  const home = process.env["HOME"];
  if (!home) {
    throw new Error('Environment variable $HOME is not set')
  }
  const tasks: Task[] = []
  for (const item of buildTasks(vars, {home})) {
    const a = await item;
    Array.isArray(a) ? tasks.push(...a) : tasks.push(a)
  }

  for (const task of tasks) {
    const shouldExecute = await task.condition();
    const status = !shouldExecute ? green("[OK]") : args["dry-run"] ? gray("[SKIP]") : yellow("[EXECUTE]");
    console.log(`${status} ${task.name}`);
    if (shouldExecute && !args["dry-run"]) {
      await task.execute();
    }
  }

  console.log(green("Provisioning completed!"));
};

const setupVars = async <T extends string[]>(keys: T): Promise<Record<T[number], string>> => {
  const filepath = `${import.meta.dirname}/../vars.json`;
  await mkdir(dirname(filepath), {recursive: true});
  if (!await exists(filepath)) {
    await writeFile(filepath, "");
  }
  const vars = JSON.parse((await readFile(filepath, "utf-8").then((s) => s || "{}")));
  for (const key of keys) {
    if (vars[key] == null) {
      const rl = createInterface({input: process.stdin, output: process.stdout});
      const value = await rl.question(`${key}: `);
      rl.close();
      if (!value) {
        console.log("abort");
        process.exit(1);
      }
      vars[key] = value;
    }
  }
  await writeFile(filepath, JSON.stringify(vars, null, 2));
  return vars as Record<T[number], string>;
};

const green = (s: string) => `\x1b[32m${s}\x1b[0m`;
const yellow = (s: string) => `\x1b[33m${s}\x1b[0m`;
const gray = (s: string) => `\x1b[90m${s}\x1b[0m`;
