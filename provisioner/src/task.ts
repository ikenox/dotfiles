import {spawn} from "node:child_process";
import {lstat, mkdir, readFile, readlink, symlink as fsSymlink} from "node:fs/promises";
import {dirname} from "node:path";
import {exists} from "./util.ts";

export type Task = {
  name: string;
  condition: Condition;
  execute: Execute;
};
export type ConditionResult =
    | { status: "not-provisioned" }
    | { status: "already-provisioned" }
    | { status: "error"; message: string };
export type Condition = () => Promise<ConditionResult> | ConditionResult;
export type Execute = () => Promise<void> | void;

export const vscodeExtensions = async (extensionsTxtFile: string): Promise<Task[]> => {
  const extensions = await readFile(extensionsTxtFile, "utf-8").then((s) => s.split("\n").map((s) => s.trim()).filter((s) => s));
  const installedExtensions = new Set(await getResult("code --list-extensions").then((r) => r.stdout.split("\n")));

  return extensions.map((ext) => ({
    name: `install vscode extension ${ext}`,
    condition: (): ConditionResult => installedExtensions.has(ext)
        ? {status: "already-provisioned"}
        : {status: "not-provisioned"},
    execute: run(`code --install-extension ${ext}`),
  }));
};

export const gitConfig = (key: string, value: string, options: { configFile: string }): Task => {
  return {
    name: `set gitconfig ${key}=${value}`,
    condition: async (): Promise<ConditionResult> => {
      const {stdout} = await getResult(`git config get -f ${options.configFile} ${key}`);
      return stdout === value ? {status: "already-provisioned"} : {status: "not-provisioned"};
    },
    execute: run(`git config -f ${options.configFile} ${key} ${value}`),
  };
};

export const symlink = (src: string, dest: string): Task => {
  return {
    name: `symlink ${src} -> ${dest}`,
    condition: async (): Promise<ConditionResult> => {
      if (!await exists(dest)) {
        return {status: "not-provisioned"};
      }
      const stat = await lstat(dest);
      if (!stat.isSymbolicLink()) {
        return {status: "error", message: `${dest} already exists and is not a symlink`};
      }
      const target = await readlink(dest);
      if (target !== src) {
        return {status: "error", message: `${dest} is a symlink to ${target}, expected ${src}`};
      }
      return {status: "already-provisioned"};
    },
    execute: async () => {
      await mkdir(dirname(dest), {recursive: true});
      await fsSymlink(src, dest);
    },
  };
};

export const defaults = (domain: string, key: string, writeArgs: string, expected: string): Task => ({
  name: `defaults ${domain} ${key}`,
  condition: async (): Promise<ConditionResult> => {
    const {stdout} = await getResult(`defaults read ${domain} '${key}'`);
    return stdout === expected ? {status: "already-provisioned"} : {status: "not-provisioned"};
  },
  execute: run(`defaults write ${domain} '${key}' ${writeArgs}`),
});

export const brewBundle = (): Task => ({
  name: "brew bundle",
  condition: async (): Promise<ConditionResult> => {
    const {success} = await getResult("brew bundle check");
    return success ? {status: "already-provisioned"} : {status: "not-provisioned"};
  },
  execute: run("brew bundle --no-upgrade"),
});

export const shell = (cmd: string, options?: { condition?: Condition }): Task => {
  return {
    name: `shell \`${cmd}\``,
    condition: options?.condition ?? ((): ConditionResult => ({status: "not-provisioned"})),
    execute: run(cmd),
  };
};

const run = (cmd: string): Execute => () => {
  return new Promise<void>((resolve, reject) => {
    const proc = spawn("bash", ["-c", cmd], {stdio: "inherit"});
    proc.on("error", reject);
    proc.on("close", (code) => {
      if (code !== 0) {
        reject(new Error(`script exited with code: ${code}`));
        return;
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

export const defaultsDictAdd = (
  domain: string,
  key: string,
  dictKey: string,
  plistValue: string,
): Task => ({
  name: `defaults dict-add ${domain} ${key} ${dictKey}`,
  condition: async (): Promise<ConditionResult> => {
    const {stdout} = await getResult(`defaults read ${domain} ${key}`);
    const pattern = new RegExp(`${dictKey}\\s*=\\s*\\{\\s*enabled\\s*=\\s*0`);
    return pattern.test(stdout) ? {status: "already-provisioned"} : {status: "not-provisioned"};
  },
  execute: run(`defaults write ${domain} ${key} -dict-add ${dictKey} '${plistValue}'`),
});

export const ifNotExists = (file: string): Condition => () =>
    exists(file).then((e): ConditionResult => e ? {status: "already-provisioned"} : {status: "not-provisioned"});

export const ifNotRunning = (processName: string): Condition => async () => {
  const {success} = await getResult(`pgrep -x '${processName}'`);
  return success ? {status: "already-provisioned"} : {status: "not-provisioned"};
};

