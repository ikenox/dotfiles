# dotfiles

## Execute provisioning

### Initial remote execution

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ikenox/dotfiles/master/provision.sh)"
```

### Local re-execution

```sh
./provision.sh
```

## Manual tasks

- Add "日本語" to 入力ソース
- Settings > Keyboard > Shortcut
    - uncheck "select next input source by ^ + space".
    - Disable Spotlight keyboard shortcut
- Settings > Keyboard > 辞書
    - Disable "スマート引用符とスマートダッシュを使用"
- Set default browser to Chrome
- Set up Touch ID
- Remove all icons from dock
- Sign-in to app store
- Migrate zsh history file from old machine
- Add SSH public key to GitHub
- Launch
    - alfred
    - karabiner-elements
    - alt-tab
- Google Chrome: login & sync settings
- Install Xcode
    - Xcode command line tools will be installed when installing Homebrew
    - xcode-select --install
- Install intellij via toolbox
- Configure alfred
    - Change hotkey -> ctrl + space
    - Change appearance to "Alfred Dark"
- Exec vim `:PlugInstall`
- Sync IntelliJ
  settings https://www.jetbrains.com/help/idea/sharing-your-ide-settings.html#IDE_settings_sync
    - login on JetBrains Toolbox
    - IntelliJ: login & "Sync Settings to JetBrains Account" > "Get Settings from Account"
- 環境設定 > Bluetooth > Bluetoothをメニューバーに表示
- Sign-in to slack with magic link
- Restart MacOS
    - Some changes by the `defaults` command will be applied after restarting
