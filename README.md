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

- Add "日本語" to "入力ソース"
- Set default browser to Chrome
- Set up Touch ID
- Sign-in to app store
- Migrate zsh history file from old machine
- Add SSH public key to GitHub
- Google Chrome: login & sync settings
- Configure alfred
    - Change hotkey -> ctrl + space
    - Change appearance to "Alfred Dark"
- Sync IntelliJ
  settings https://www.jetbrains.com/help/idea/sharing-your-ide-settings.html#IDE_settings_sync
    - login on JetBrains Toolbox
    - IntelliJ: login & "Sync Settings to JetBrains Account" > "Get Settings from Account"
- Sign-in to slack with magic link
- Restart MacOS
    - Some changes by the `defaults` command will be applied after restarting
