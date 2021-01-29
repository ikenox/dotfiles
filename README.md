## First time

```sh
bash -c 'ruby -e "$({ curl -fsSL https://raw.github.com/ikenox/dotfiles/master/provision-tasks.rb; curl -fsSL https://raw.githubusercontent.com/ikenox/equil/0.2.0/equil.rb; })" essentials'
```

## Second time or later

```sh
bash -c 'ruby -e "$({ cat ~/.dotfiles/provision-tasks.rb; curl -fsSL https://raw.githubusercontent.com/ikenox/equil/0.2.0/equil.rb; })" essentials'
```

## TODO list which should be automated

- add ssh public key to github
- mac dark mode
- launch
    - karabiner-elements
    - hyperswitch
- install & setup chrome extensions
    - bitwarden
- install xcode
- install xcode command line tools
- install intellij
- disable spotlight
- settings for google japanese input https://qiita.com/normalsalt/items/017031713f6577e488aa
- enable key repeat?
- change a time until display auto-off -> 5min
- configure alfred 
    - change hotkey -> ctrl + space
    - change appearance to "Alfred Dark"
- configure hyperswitch
    - check: run hyperswitch in the background
    - check: include windows from other screens
    - check: use shift to cycle backwards
    - check: show hyperswitch in the menu bar
- exec vim `:PlugInstall`
- Settings > Keyboard > Shortcut > uncheck "select next input source by ^ + space".
- sync IntelliJ settings https://www.jetbrains.com/help/idea/sharing-your-ide-settings.html#IDE_settings_sync
    - login on JetBrains Toolbox
    - IntelliJ: login & "Sync Settings to JetBrains Account" > "Get Settings from Account"
- "fish -c fisher" ?
- change settings for ことえり "￥キーを入力する文字: \"
