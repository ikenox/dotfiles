import { ensureFile, ensureSymlink, exists } from "jsr:@std/fs";
import { gray, green, yellow } from "jsr:@std/fmt/colors";
import { parseArgs } from "jsr:@std/cli/parse-args";

const execute = async () => {
  const args = parseArgs(Deno.args, {
    boolean: ["dry-run"],
  });

  const vars = await setupVars("username", "email");
  console.log("vars:", vars);

  const home = Deno.env.get("HOME");

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
    symlink(`${home}/.dotfiles/vim/.vimrc`, `${home}/.vimrc`),
    symlink(`${home}/.dotfiles/vim/.vimrc.keymap`, `${home}/.vimrc.keymap`),
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
    shell("defaults write -g com.apple.trackpad.scaling -int 3"),
    shell("defaults write -g InitialKeyRepeat -int 15"),
    shell("defaults write -g KeyRepeat -int 2"),
    shell("defaults -currentHost write -globalDomain com.apple.mouse.tapBehavior -int 1"),
    shell("defaults write -g AppleShowAllExtensions -bool true"),
    shell("defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true"),
    shell(`defaults write com.apple.controlstrip MiniCustomized '( "com.apple.system.brightness", "com.apple.system.volume", "com.apple.system.mute", "com.apple.system.sleep")'`),
    shell("defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false"),
    shell("defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false"),
    shell("defaults write -g ApplePressAndHoldEnabled -bool false"),
    shell("defaults write com.lwouis.alt-tab-macos windowDisplayDelay 100"),
    shell("defaults write com.apple.inputmethod.Kotoeri JIMPrefCharacterForYenKey 1"), // ことえり > ￥キーで入力する文字: \
    shell("defaults write -g NSAutomaticSpellingCorrectionEnabled 1"), // 環境設定 > キーボード > ユーザ辞書 > 英字入力中にスペルを自動変換
    shell('defaults write -g AppleInterfaceStyle -string "Dark"'), // Dark mode
    // vscode extension
    ...(await vscodeExtensions(`${home}/.dotfiles/vscode/extensions.txt`)),
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
  const extensions = await Deno.readTextFile(extensionsTxtFile).then((s) => s.split("\n").map((s) => s.trim()).filter((s) => s));
  const installedExtensions = new Set(await getResult("code --list-extensions").then((r) => r.stdout.split("\n")));

  return extensions.map((ext) => ({
    name: `install vscode extension ${ext}`,
    condition: () => !installedExtensions.has(ext),
    execute: run(`code --install-extension ${ext}`),
  }));
};

const gitConfig = (key: string, value: string, options: {
  configFile: string;
}): Task => {
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
    execute: () => ensureSymlink(src, dest),
  };
};

const shell = (cmd: string, options?: {
  condition?: Condition;
}): Task => {
  return {
    name: `shell \`${cmd}\``,
    condition: options?.condition ?? (() => true),
    execute: run(cmd),
  };
};

const run = (cmd: string): Execute => async () => {
  const command = new Deno.Command("bash", {
    args: ["-c", cmd],
    stdout: "piped",
    stderr: "piped",
  });
  const process = command.spawn();

  await Promise.all([
    process.stdout.pipeTo(Deno.stdout.writable, { preventClose: true }),
    process.stderr.pipeTo(Deno.stderr.writable, { preventClose: true }),
  ]);
  const { code, success } = await process.status;
  if (!success) {
    console.error("ERROR: script exited with code:", code);
    Deno.exit(1);
  }
};

const getResult = async (cmd: string) => {
  const command = new Deno.Command("bash", {
    args: ["-c", cmd],
    stdout: "piped",
    stderr: "piped",
  });
  const process = command.spawn();
  const output = await process.output();
  const { code, success } = await process.status;
  return { success, code, stdout: new TextDecoder().decode(output.stdout).trimEnd() };
};

const ifNotExists = (
  file: string,
): Condition =>
() => exists(file).then((exists) => !exists);

const setupVars = async <T extends string[]>(...keys: T): Promise<Record<T[number], string>> => {
  const filepath = `${import.meta.dirname}/vars.json`;
  await ensureFile(filepath);
  const vars = JSON.parse(await Deno.readTextFile(filepath).then((s) => s || "{}"));
  for (const key of keys) {
    if (vars[key] == null) {
      const value = prompt(`${key}:`);
      if (!value) {
        console.log("abort");
        Deno.exit(1);
      }
      vars[key] = value;
    }
  }
  await Deno.writeTextFile(filepath, JSON.stringify(vars, null, 2));
  return vars as Record<T[number], string>;
};

void execute();
