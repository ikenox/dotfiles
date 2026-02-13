import {spawn} from "node:child_process";
import {mkdir, readFile, symlink as fsSymlink} from "node:fs/promises";
import {dirname} from "node:path";
import {exists} from "./util.js";

export type Task = {
  name: string;
  condition: Condition;
  execute: Execute;
};
export type Condition = () => Promise<boolean> | boolean;
export type Execute = () => Promise<void> | void;

export const vscodeExtensions = async (extensionsTxtFile: string): Promise<Task[]> => {
  const extensions = await readFile(extensionsTxtFile, "utf-8").then((s) => s.split("\n").map((s) => s.trim()).filter((s) => s));
  const installedExtensions = new Set(await getResult("code --list-extensions").then((r) => r.stdout.split("\n")));

  return extensions.map((ext) => ({
    name: `install vscode extension ${ext}`,
    condition: () => !installedExtensions.has(ext),
    execute: run(`code --install-extension ${ext}`),
  }));
};

export const gitConfig = (key: string, value: string, options: { configFile: string }): Task => {
  return {
    name: `set gitconfig ${key}=${value}`,
    condition: async () => {
      const {stdout} = await getResult(`git config get -f ${options.configFile} ${key}`);
      return stdout !== value;
    },
    execute: run(`git config -f ${options.configFile} ${key} ${value}`),
  };
};

export const symlink = (src: string, dest: string): Task => {
  return {
    name: `symlink ${src} -> ${dest}`,
    condition: ifNotExists(dest),
    execute: async () => {
      await mkdir(dirname(dest), {recursive: true});
      await fsSymlink(src, dest);
    },
  };
};

export const shell = (cmd: string, options?: { condition?: Condition }): Task => {
  return {
    name: `shell \`${cmd}\``,
    condition: options?.condition ?? (() => true),
    execute: run(cmd),
  };
};

const run = (cmd: string): Execute => () => {
  return new Promise<void>((resolve, reject) => {
    const proc = spawn("bash", ["-c", cmd], {stdio: "inherit"});
    proc.on("error", reject);
    proc.on("close", (code) => {
      if (code !== 0) {
        console.error("ERROR: script exited with code:", code);
        process.exit(1);
      }
      resolve();
    });
  });
};

const getResult = (cmd: string): Promise<{
  success: boolean;
  code: number | null;
  stdout: string
}> => {
  return new Promise((resolve, reject) => {
    const proc = spawn("bash", ["-c", cmd], {stdio: ["inherit", "pipe", "pipe"]});
    let stdout = "";
    proc.stdout.on("data", (data: Buffer) => {
      stdout += data.toString();
    });
    proc.on("error", reject);
    proc.on("close", (code) => {
      resolve({success: code === 0, code, stdout: stdout.trimEnd()});
    });
  });
};

export const ifNotExists = (file: string): Condition => () => exists(file).then((e) => !e);

