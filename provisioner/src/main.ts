import {execute} from "./executor.ts";
import {brewBundle, defaults, gitConfig, ifNotExists, shell, symlink, vscodeExtensions} from "./task.ts";

void execute(['username', 'email'], ({username, email}, {home}) => [
  brewBundle(),
  // configure git
  gitConfig("user.name", username, {configFile: "~/.gitconfig.local"}),
  gitConfig("user.email", email, {configFile: "~/.gitconfig.local"}),
  // ssh-key
  shell(`ssh-keygen -q -C '${email}' -t ed25519 -f ~/.ssh/id_ed25519 -N ''`, {
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
  symlink(`${home}/.dotfiles/claude/commands`, `${home}/.claude/commands`),
  symlink(`${home}/.dotfiles/claude/skills`, `${home}/.claude/skills`),
  symlink(`${home}/.dotfiles/claude/agents`, `${home}/.claude/agents`),
  symlink(`${home}/.dotfiles/claude/CLAUDE.md`, `${home}/.claude/CLAUDE.md`),
  symlink(`${home}/.dotfiles/vscode/settings.json`, `${home}/Library/Application Support/Code/User/settings.json`),
  symlink(`${home}/.dotfiles/vscode/keybindings.json`, `${home}/Library/Application Support/Code/User/keybindings.json`),
  symlink(`${home}/.dotfiles/vscode/tasks.json`, `${home}/Library/Application Support/Code/User/tasks.json`),
  // osx defaults
  defaults("com.apple.dock", "autohide", "-bool true", "1"),
  defaults("com.apple.dock", "persistent-apps", "-array", "(\n)"),
  defaults("com.apple.dock", "tilesize", "-int 55", "55"),
  defaults("com.apple.finder", "AppleShowAllFiles", "-bool true", "1"),
  defaults("com.apple.finder", "NewWindowTarget", "-string PfDe", "PfDe"),
  defaults("com.apple.finder", "NewWindowTargetPath", `-string 'file://${home}/'`, `file://${home}/`),
  defaults("com.apple.screencapture", "disable-shadow", "-bool true", "1"),
  defaults("com.apple.screencapture", "name", "-string screenshot", "screenshot"),
  defaults("com.apple.screencapture", "location", `-string '${home}/screenshots/'`, `${home}/screenshots/`),
  defaults("com.apple.desktopservices", "DSDontWriteNetworkStores", "-bool true", "1"),
  defaults("com.apple.controlstrip", "MiniCustomized",
    "-array 'com.apple.system.brightness' 'com.apple.system.volume' 'com.apple.system.mute' 'com.apple.system.sleep'",
    `(
    "com.apple.system.brightness",
    "com.apple.system.volume",
    "com.apple.system.mute",
    "com.apple.system.sleep"
)`),
  defaults("com.microsoft.VSCode", "ApplePressAndHoldEnabled", "-bool false", "0"),
  defaults("com.microsoft.VSCodeInsiders", "ApplePressAndHoldEnabled", "-bool false", "0"),
  defaults("com.lwouis.alt-tab-macos", "windowDisplayDelay", "-int 100", "100"),
  defaults("com.apple.inputmethod.Kotoeri", "JIMPrefCharacterForYenKey", "-int 1", "1"), // ことえり > ￥キーで入力する文字: \
  defaults("-g", "com.apple.mouse.tapBehavior", "-int 1", "1"),
  defaults("-g", "com.apple.trackpad.scaling", "-int 3", "3"),
  defaults("-g", "InitialKeyRepeat", "-int 15", "15"),
  defaults("-g", "KeyRepeat", "-int 2", "2"),
  defaults("-g", "AppleShowAllExtensions", "-bool true", "1"),
  defaults("-g", "ApplePressAndHoldEnabled", "-bool false", "0"),
  defaults("-g", "NSAutomaticSpellingCorrectionEnabled", "-int 1", "1"), // 環境設定 > キーボード > ユーザ辞書 > 英字入力中にスペルを自動変換
  defaults("-g", "AppleInterfaceStyle", "-string Dark", "Dark"), // Dark mode
  // vscode extension
  vscodeExtensions(`${home}/repos/github.com/ikenox/dotfiles/vscode/extensions.txt`),
  // install vim-plug
  shell("curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim", {
    condition: ifNotExists(`${home}/.vim/autoload/plug.vim`),
  }),
  // rustup
  shell("curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh", {
    condition: ifNotExists(`${home}/.cargo`),
  }),
])
