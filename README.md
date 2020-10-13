## First time

```sh
bash -c 'ruby -e "$({ curl -fsSL https://raw.github.com/ikenox/dotfiles/master/provision-tasks.rb; curl -fsSL https://raw.githubusercontent.com/ikenox/equil/0.2.0/equil.rb; })" essentials'
```

## Second time or later

```sh
bash -c 'ruby -e "$({ cat ~/.dotfiles/provision-tasks.rb; curl -fsSL https://raw.githubusercontent.com/ikenox/equil/0.2.0/equil.rb; })" essentials'
```

## TODO list which has to be configured manually

- install & setup chrome extensions
    - bitwarden
- install xcode
- install xcode command line tools
- install intellij
- disable spotlight
- settings for かな入力 https://qiita.com/normalsalt/items/017031713f6577e488aa
- enable key repeat
