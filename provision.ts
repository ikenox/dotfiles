import { existsSync, mkdirSync, symlinkSync, writeFileSync } from "node:fs";
import { readFile, writeFile } from "node:fs/promises";
import { dirname } from "node:path";
import { parseArgs } from "node:util";
import { spawn } from "node:child_process";
import { createInterface } from "node:readline/promises";

const green = (s: string) => `\x1b[32m${s}\x1b[0m`;
const yellow = (s: string) => `\x1b[33m${s}\x1b[0m`;
const gray = (s: string) => `\x1b[90m${s}\x1b[0m`;

const execute = async () => {
  const { values: args } = parseArgs({
    args: process.argv.slice(2),
    options: {
      "dry-run": { type: "boolean", default: false },
    },
  });

  const vars = await setupVars("username", "email");
  console.log("vars:", vars);

  const home = process.env.HOME;

  const tasks: Task[] = [
    shell("brew bundle --no-upgrade"),
    // configure git
    gitConfig("user.name", vars.username, { configFile: "~/.gitconfig.local" }),
    gitConfig("user.email", vars.email, { configFile: "~/.gitconfig.local" }),
    // ssh-key
    shell(`ssh-keygen -q -C '${vars.email}' -t ed25519 -f ~/.ssh/id_ed25519 -N ''`, {
      condition: ifNotExists(`${home}/.ssh/id_ed25519`),
    }),
    // symlinks
    symlink(`${home}/repos/github.com/ikenox/dotfiles`, `${home}/.dotfiles`),
    symlink(`${home}/.dotfiles/karabiner`, `${home}/.config/karabiner`),
    symlink(`${home}/.dotfiles/ghostty/config`, `${home}/.config/ghostty/config`),
    symlink(`${home}/.dotfiles/peco/config.json`, `${home}/.config/peco/config.json`),
    symlink(`${home}/.dotfiles/ag/agignore`, `${home}/.agignore`),
    symlink(`${home}/.dotfiles/intellij/ideavimrc`, `${home}/.ideavimrc`),
    symlink(`${home}/.dotfiles/jupyter/lab/user-settings`, `${home}/.jupyter/lab/user-settings`),
    symlink(`${home}/.dotfiles/git/gitconfig`, `${home}/.gitconfig`),
    symlink(`${home}/.dotfiles/git/gitignore`, `${home}/.gitignore`),
    symlink(`${home}/.dotfiles/zsh/.zshrc`, `${home}/.zshrc`),
    symlink(`${home}/.dotfiles/starship/starship.toml`, `${home}/.config/starship.toml`),
    symlink(`${home}/.dotfiles/vim/vimrc`, `${home}/.vimrc`),
    symlink(`${home}/.dotfiles/vim/vimrc.keymap`, `${home}/.vimrc.keymap`),
    symlink(`${home}/.dotfiles/claude/settings.json`, `${home}/.claude/settings.json`),
    symlink(`${home}/.dotfiles/claude/commands`, `${home}/.claude/commands/`),
    symlink(`${home}/.dotfiles/claude/skills`, `${home}/.claude/skills/`),
    symlink(`${home}/.dotfiles/claude/agents`, `${home}/.claude/agents/`),
    symlink(`${home}/.dotfiles/claude/CLAUDE.md`, `${home}/.claude/CLAUDE.md`),
    symlink(`${home}/.dotfiles/vscode/settings.json`, `${home}/Library/Application Support/Code/User/settings.json`),
    symlink(`${home}/.dotfiles/vscode/keybindings.json`, `${home}/Library/Application Support/Code/User/keybindings.json`),
    symlink(`${home}/.dotfiles/vscode/tasks.json`, `${home}/Library/Application Support/Code/User/tasks.json`),
    // osx defaults
    shell("defaults write com.apple.dock autohide -bool true"),
    shell("defaults write com.apple.dock persistent-apps -array"),
    shell("defaults write com.apple.dock tilesize -int 55"),
    shell("defaults write com.apple.finder AppleShowAllFiles YES"),
    shell('defaults write com.apple.finder NewWindowTarget -string "PfDe"'),
    shell(`defaults write com.apple.finder NewWindowTargetPath -string "file://${home}/"`),
    shell("defaults write com.apple.Safari IncludeInternalDebugMenu -bool true"),
    shell('defaults write com.apple.screencapture "disable-shadow" -bool yes'),
    shell("defaults write com.apple.screencapture name screenshot"),
    shell("defaults write com.apple.screencapture location ~/screenshots/"),
    shell("defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true"),
    shell(`defaults write com.apple.controlstrip MiniCustomized '( "com.apple.system.brightness", "com.apple.system.volume", "com.apple.system.mute", "com.apple.system.sleep")'`),
    shell("defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false"),
    shell("defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false"),
    shell("defaults write com.lwouis.alt-tab-macos windowDisplayDelay 100"),
    shell("defaults write com.apple.inputmethod.Kotoeri JIMPrefCharacterForYenKey 1"), // ことえり > ￥キーで入力する文字: \
    shell("defaults write -g com.apple.mouse.tapBehavior -int 1"),
    shell("defaults write -g com.apple.trackpad.scaling -int 3"),
    shell("defaults write -g InitialKeyRepeat -int 15"),
    shell("defaults write -g KeyRepeat -int 2"),
    shell("defaults write -g AppleShowAllExtensions -bool true"),
    shell("defaults write -g ApplePressAndHoldEnabled -bool false"),
    shell("defaults write -g NSAutomaticSpellingCorrectionEnabled 1"), // 環境設定 > キーボード > ユーザ辞書 > 英字入力中にスペルを自動変換
    shell('defaults write -g AppleInterfaceStyle -string "Dark"'), // Dark mode
    // vscode extension
    ...(await vscodeExtensions(`${home}/repos/github.com/ikenox/dotfiles/vscode/extensions.txt`)),
    // install vim-plug
    shell("curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim", {
      condition: ifNotExists(`${home}/.vim/autoload/plug.vim`),
    }),
    // rustup
    shell("curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh", {
      condition: ifNotExists(`${home}/.cargo`),
    }),
  ];

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

type Task = {
  name: string;
  condition: Condition;
  execute: Execute;
};
type Condition = () => Promise<boolean> | boolean;
type Execute = () => Promise<void> | void;

const vscodeExtensions = async (extensionsTxtFile: string): Promise<Task[]> => {
  const extensions = await readFile(extensionsTxtFile, "utf-8").then((s) => s.split("\n").map((s) => s.trim()).filter((s) => s));
  const installedExtensions = new Set(await getResult("code --list-extensions").then((r) => r.stdout.split("\n")));

  return extensions.map((ext) => ({
    name: `install vscode extension ${ext}`,
    condition: () => !installedExtensions.has(ext),
    execute: run(`code --install-extension ${ext}`),
  }));
};

const gitConfig = (key: string, value: string, options: { configFile: string }): Task => {
  return {
    name: `set gitconfig ${key}=${value}`,
    condition: async () => {
      const { stdout } = await getResult(`git config get -f ${options.configFile} ${key}`);
      return stdout !== value;
    },
    execute: run(`git config -f ${options.configFile} ${key} ${value}`),
  };
};

const symlink = (src: string, dest: string): Task => {
  return {
    name: `symlink ${src} -> ${dest}`,
    condition: ifNotExists(dest),
    execute: () => {
      mkdirSync(dirname(dest), { recursive: true });
      symlinkSync(src, dest);
    },
  };
};

const shell = (cmd: string, options?: { condition?: Condition }): Task => {
  return {
    name: `shell \`${cmd}\``,
    condition: options?.condition ?? (() => true),
    execute: run(cmd),
  };
};

const run = (cmd: string): Execute => () => {
  return new Promise<void>((resolve, reject) => {
    const proc = spawn("bash", ["-c", cmd], { stdio: "inherit" });
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

const getResult = (cmd: string): Promise<{ success: boolean; code: number | null; stdout: string }> => {
  return new Promise((resolve, reject) => {
    const proc = spawn("bash", ["-c", cmd], { stdio: ["inherit", "pipe", "pipe"] });
    let stdout = "";
    proc.stdout.on("data", (data: Buffer) => {
      stdout += data.toString();
    });
    proc.on("error", reject);
    proc.on("close", (code) => {
      resolve({ success: code === 0, code, stdout: stdout.trimEnd() });
    });
  });
};

const ifNotExists = (file: string): Condition => () => !existsSync(file);

const setupVars = async <T extends string[]>(...keys: T): Promise<Record<T[number], string>> => {
  const filepath = `${import.meta.dirname}/vars.json`;
  mkdirSync(dirname(filepath), { recursive: true });
  if (!existsSync(filepath)) {
    writeFileSync(filepath, "");
  }
  const vars = JSON.parse((await readFile(filepath, "utf-8").then((s) => s || "{}")));
  for (const key of keys) {
    if (vars[key] == null) {
      const rl = createInterface({ input: process.stdin, output: process.stdout });
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

void execute();
