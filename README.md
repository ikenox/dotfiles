# dotfiles

## Execute provisioning

### Initial execution from remote

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ikenox/dotfiles/master/provision.sh)"
```

### Re-execution on local

```sh
./provision.sh
```

## Manual tasks

- Add "日本語" to 入力ソース
- Settings > Keyboard > Shortcut
    - uncheck "select next input source by ^ + space".
    - disable spotlight from keyboard shortcut
- Set default browser to Chrome
- Setup Touch ID
- Remove all icons from dock
- Sign-in to app store
- Migrate zsh history file from old machine
- Add ssh public key to github
- Launch
    - alfred
    - karabiner-elements
    - alt-tab
- Google Chrome: login & sync settings
- Install Xcode
    - Xcode command line tools will be installed when installing homebrew
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
    - Some changes by `defaults` command will be applied after restarting
