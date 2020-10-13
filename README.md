## First time

```sh
bash -c 'ruby -e "$({ curl -fsSL https://raw.github.com/ikenox/dotfiles/master/provision-tasks.rb; curl -fsSL https://raw.githubusercontent.com/ikenox/equil/0.2.0/equil.rb; })" essentials'
```

## Second time or later

```sh
bash -c 'ruby -e "$({ cat ~/.dotfiles/provision-tasks.rb; curl -fsSL https://raw.githubusercontent.com/ikenox/equil/0.2.0/equil.rb; })" essentials'
```

## TODO list which should be automated

- install & setup chrome extensions
    - bitwarden
- install xcode
- install xcode command line tools
- install intellij
- disable spotlight
- settings for google japanese input https://qiita.com/normalsalt/items/017031713f6577e488aa
- enable key repeat?
- change a time until display auto-off -> 5min
- configure alfred hotkey -> ctrl + space
- configure hyperswitch
    - check: run hyperswitch in the background
    - check: include windows from other screens
    - check: use shift to cycle backwards
- exec vim `:PlugInstall`
- Settings > Keyboard > Shortcut > uncheck "select next input source by ^ + space".

