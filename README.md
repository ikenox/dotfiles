## First time

```sh
bash -c 'ruby -e "$({ curl -fsSL https://raw.github.com/ikenox/dotfiles/master/provision-tasks.rb; curl -fsSL https://raw.githubusercontent.com/ikenox/equil/0.2.0/equil.rb; })" essentials'
```

## Second time or later

```sh
bash -c 'ruby -e "$({ cat ~/.dotfiles/provision-tasks.rb; curl -fsSL https://raw.githubusercontent.com/ikenox/equil/0.2.0/equil.rb; })" essentials'
```

## TODO list which should be automated

- remove all icons from dock
- sign-in to app store
- migrate fish history file from old machine
- add ssh public key to github
- set mac dark mode
- launch
    - alfred
    - karabiner-elements
    - hyperswitch
- chrome: login & sync settings
- install xcode
    - xcode command line tools will be installed when installing homebrew
    - xcode-select --install
- install jetbrains toolbox
- install intellij via toolbox
- Settings > Keyboard > Shortcut
    - uncheck "select next input source by ^ + space".
    - disable spotlight from keyboard shortcut
- add "日本語" to 入力ソース
- configure alfred
    - change hotkey -> ctrl + space
    - change appearance to "Alfred Dark"
- configure hyperswitch
    - check: run hyperswitch in the background
    - check: include windows from other screens
    - check: use shift to cycle backwards
    - check: show hyperswitch in the menu bar
- exec vim `:PlugInstall`
- sync IntelliJ settings https://www.jetbrains.com/help/idea/sharing-your-ide-settings.html#IDE_settings_sync
    - login on JetBrains Toolbox
    - IntelliJ: login & "Sync Settings to JetBrains Account" > "Get Settings from Account"
- change settings for ことえり "￥キーで入力する文字: \"
- 環境設定 > Bluetooth > Bluetoothをメニューバーに表示
- 環境設定 > キーボード > ユーザ辞書 > uncheck "英字入力中にスペルを自動変換"
- add "ひらがな(Google)" to "キーボード > 入力ソース"
- karabiner-elements
    - use version 12.10.0
        - case A: can't allow karabiner-elements in Security & Policy window -> https://spring-mt.hatenablog.com/entry/2020/10/01/125713
        - case B: karabiner_grabber is not found -> https://github.com/pqrs-org/Karabiner-Elements/issues/1867#issue-451740679
- sign-in to slack with magic link
- iterm2
    - If color theme is not applied well: change "Profiles -> Colors -> Color Presets" will solve the problem
- restart MacOS
    - some setting changes by `defaults` command will be applied after restarting
