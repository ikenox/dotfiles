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

  const errors: { name: string; message: string }[] = [];
  for (const task of tasks) {
    const result = await task.condition();
    switch (result.status) {
      case "already-provisioned":
        console.log(`${green("[OK]")} ${task.name}`);
        break;
      case "error":
        console.error(`${red("[ERROR]")} ${task.name}: ${result.message}`);
        errors.push({name: task.name, message: result.message});
        break;
      case "not-provisioned":
        console.log(`${yellow("[EXECUTE]")} ${task.name}`);
        if (!args["dry-run"]) {
          await Promise.resolve(task.execute()).catch((e) => {
            const message = e instanceof Error ? e.message : String(e);
            console.error(`${red("[ERROR]")} ${task.name}: ${message}`);
            errors.push({name: task.name, message});
          });
        }
        break;
    }
  }

  if (errors.length > 0) {
    console.error(`\n${red(`Provisioning completed with ${errors.length} error(s):`)}`);
    for (const {name} of errors) {
      console.error(`  - ${name}`);
    }
    process.exit(1);
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

const red = (s: string) => `\x1b[31m${s}\x1b[0m`;
const green = (s: string) => `\x1b[32m${s}\x1b[0m`;
const yellow = (s: string) => `\x1b[33m${s}\x1b[0m`;
const gray = (s: string) => `\x1b[90m${s}\x1b[0m`;
