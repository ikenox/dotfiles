import {execute} from "./executor.js";
import {gitConfig, ifNotExists, shell, symlink, vscodeExtensions} from "./task.js";

void execute(['username', 'email'], ({username, email}, {home}) => [
  shell("brew bundle --no-upgrade"),
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
