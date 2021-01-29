def equil
  task :essentials do
    task :init do
      #task :xcode, 'xcode-select --install'

      task :install_homebrew, if_err('which brew'),
           '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
      task :tap_brew_cask, if_err('brew tap | grep homebrew/cask'), 'brew tap caskroom/cask'

      task :install_git, if_err("ls /usr/local/Cellar/#{package}"), 'brew install git'
      task brew_upgrade 'git'
      task symlink '~/.dotfiles/git/gitignore', '~/.gitignore'

      ghq_root = '~/repos'
      task :dotfiles_repo do
        host = 'github.com'
        repo = 'ikenox/dotfiles'
        dotfiles_origin_dir = "#{ghq_root}/#{host}/#{repo}"
        task :clone_dotfiles, if_not_exist(dotfiles_origin_dir), "git clone git@#{host}:#{repo}.git #{dotfiles_origin_dir}"
        task symlink dotfiles_origin_dir, '~/.dotfiles'
      end
      task :gitconfig do
        task symlink '~/.dotfiles/git/gitconfig', '~/.gitconfig'
        task if_err('git config ghq.root'), "git config -f ~/.gitconfig.local ghq.root #{ghq_root}"
      end
    end

    task :setup_git do
      task :set_username, if_err("git config user.name"), -> {
        print "please type your git user.name: "
        name = STDIN.gets.chomp
        "git config -f ~/.gitconfig.local user.name '#{name}'"
      }
      task :set_email, if_err("git config user.email"), -> {
        print "please type your git user.email: "
        email = STDIN.gets.chomp
        "git config -f ~/.gitconfig.local user.email '#{email}'"
      }
      task brew 'ghq'
      task brew_upgrade 'ghq'
    end

    task :karabiner_elements do
      # karabiner-elements 13 doesn't work on catalina 10.15.7
      #task brew_cask 'karabiner-elements'
      #task brew_cask_upgrade 'karabiner-elements'
      task symlink '~/.dotfiles/karabiner', '~/.config/karabiner'
    end

    task :setup_vim do
      task brew 'vim'
      #task brew_upgrade 'vim'
      task :install_vim_plug, if_not_exist("~/.vim/autoload/plug.vim"),
           "curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
      task symlink '~/.dotfiles/vim/vimrc', '~/.vimrc'
      task symlink '~/.dotfiles/vim/vimrc.keymap', '~/.vimrc.keymap'
    end

    task :iterm do
      task brew_cask 'iterm2'
      task brew_cask_upgrade 'iterm2'
      task symlink '~/.dotfiles/iterm2/com.googlecode.iterm2.plist', '~/Library/Preferences/com.googlecode.iterm2.plist'
      task 'killall cfprefsd'
    end

    task :tmux do
      task brew 'tmux'
      task brew_upgrade 'tmux'
      task symlink '~/.dotfiles/tmux/tmux.conf', '~/.tmux.conf'
      task if_not_exist('~/.tmux/plugins/tpm'), 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm'
    end


    task :peco do
      task brew 'peco'
      task brew_upgrade 'peco'
      task symlink '~/.dotfiles/peco/config.json', '~/.config/peco/config.json'
    end
    task brew 'fzf'
    task brew 'jq'
    task brew 'mas'
    task brew 'gnu-sed'
    task brew_upgrade 'fzf'
    task brew_upgrade 'jq'
    task brew_upgrade 'mas'
    task brew_upgrade 'gnu-sed'
    task :ag do
      task brew 'ag'
      task brew_upgrade 'ag'
      task symlink '~/.dotfiles/ag/agignore', '~/.agignore'
    end

    task :fish do
      task brew 'fish'
      task brew_upgrade 'fish'
      task symlink '~/.dotfiles/fish', '~/.config/fish'
      task :fisherman, if_not_exist('~/.config/fish/functions/fisher.fish'),
           'curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher'
      task :set_default_shell do
        task :add_shell, if_err("cat /etc/shells | grep $(which fish)"),
             "sudo bash -c 'echo $(which fish) >> /etc/shells'"
        # task :add_shell, if_err("echo $SHELL | grep fish") do
        #   sh "sudo chsh -s $(which fish)"
        # end
      end
      task :fish_package, if_err('fish -c "fisher ls | xargs -I% grep % -a ~/.dotfiles/fish/fishfile"'), 'fish -c "fisher"'
    end

    # todo: set keyboard -> 入力ソース -> ひらがな(google)
    task :ime do
      task brew_cask 'google-japanese-ime'
    end

    task brew_cask 'hyperswitch'
    task brew_cask_upgrade 'hyperswitch'

    task :osx_defaults do
      task 'defaults write com.apple.dock autohide -bool true'
      task 'defaults write com.apple.dock persistent-apps -array'
      task 'defaults write com.apple.dock tilesize -int 55'
      # task 'defaults write com.apple.dock wvous-bl-corner -int 10'
      # task 'defaults write com.apple.dock wvous-bl-modifier -int 0'
      # todo killall if updated
      # killall Dock'

      task 'defaults write com.apple.finder AppleShowAllFiles YES'
      task 'defaults write com.apple.finder NewWindowTarget -string "PfDe"'
      task 'defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"'
      # todo killall if updated
      # killall Finder'

      task 'defaults write com.apple.Safari IncludeInternalDebugMenu -bool true'

      task 'defaults write com.apple.screencapture "disable-shadow" -bool yes'
      task 'defaults write com.apple.screencapture name screenshot'
      task 'defaults write com.apple.screencapture location ~/screenshots/'

      # todo needs restart
      task 'defaults write -g com.apple.trackpad.scaling -int 3'
      task 'defaults write -g InitialKeyRepeat -int 15'
      task 'defaults write -g KeyRepeat -int 2'
      task 'defaults -currentHost write -globalDomain com.apple.mouse.tapBehavior -int 1'

      task 'defaults write -g AppleShowAllExtensions -bool true'
      task 'defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true'

      # ctrl + / -> next window in the same app
      # task 'defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 27 "{ enabled = 1; value =                 { parameters = ( 121, 16, 262144); type = standard; }; }""'
      #
      # TouchBar layout
      task 'defaults write com.apple.controlstrip MiniCustomized \'( "com.apple.system.brightness", "com.apple.system.volume", "com.apple.system.mute", "com.apple.system.sleep")\''
      # task 'killall SystemUIServer'
    end

    task :intellij do
      task brew_cask "jetbrains-toolbox"
      task symlink '~/.dotfiles/intellij/ideavimrc', '~/.ideavimrc'
    end

    task :gcloud do
      task brew_cask 'google-cloud-sdk'
      task brew_cask_upgrade 'google-cloud-sdk'
      task 'CLOUDSDK_PYTHON=/usr/bin/python gcloud components update'
      #task if_err('CLOUDSDK_PYTHON=/usr/bin/python gcloud components list 2>/dev/null | grep app-engine-java'),
      #     'CLOUDSDK_PYTHON=/usr/bin/python gcloud components install app-engine-java'
    end

    task :python do
      task symlink '~/.dotfiles/matplotlib/matplotlibrc', '~/.matplotlibrc'
      task :pyenv do
        task brew 'pyenv'
        task brew 'pyenv-virtualenv'
        task brew_upgrade 'pyenv'
        task brew_upgrade 'pyenv-virtualenv'
      end
    end

    #task :java do
    #  task brew 'jenv'
    #  task brew_cask 'java'
    #  task if_not_exist('~/.dotfiles/fish/conf.d/jenv.fish'),
    #       'echo "set PATH $HOME/.jenv/bin $PATH" > ~/.dotfiles/fish/conf.d/jenv.fish'
    #  task if_not_exist('~/.config/fish/jenv.fish'),
    #       'curl https://raw.githubusercontent.com/gcuisinier/jenv/master/fish/jenv.fish > ~/.config/fish/jenv.fish'
    #  task if_not_exist('~/.config/fish/export.fish'),
    #       'curl https://raw.githubusercontent.com/gcuisinier/jenv/master/fish/export.fish > ~/.config/fish/export.fish'
    #end

    task :vscode do
      task brew_cask 'visual-studio-code'
      task symlink '~/.dotfiles/vscode/settings.json', '~/Library/Application\ Support/Code/User/settings.json'
      task symlink '~/.dotfiles/vscode/keybindings.json', '~/Library/Application\ Support/Code/User/keybindings.json'
      task 'cat ~/.dotfiles/vscode/extensions.txt | while read line; do code --install-extension $line; done'
      task 'defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false'
      task 'defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false'
      task 'defaults write -g ApplePressAndHoldEnabled -bool false'
    end

    task :applications do
      task brew_cask 'slack'
      task brew_cask 'alfred' # todo change hotkey from gui
      task brew_cask 'caffeine'
      task brew_cask 'discord'
      task brew_cask 'osxfuse'
      task brew_cask_upgrade 'slack'
      task brew_cask_upgrade 'alfred' # todo change hotkey from gui
      task brew_cask_upgrade 'caffeine'
      task brew_cask_upgrade 'discord'
      task brew_cask_upgrade 'osxfuse'

      # tood need login app store
      task mas 409183694 # keynote
      task mas 409203825 # Numbers
      task mas 409201541 # Pages
      task mas 539883307 # LINE
      task mas 485812721 # TweetDeck
      task mas 405399194 # Kindle
      task mas_upgrade 409183694 # keynote
      task mas_upgrade 409203825 # Numbers
      task mas_upgrade 409201541 # Pages
      task mas_upgrade 539883307 # LINE
      task mas_upgrade 485812721 # TweetDeck
      task mas_upgrade 405399194 # Kindle
    end

    # todo macos
    # - disable spotlight
    # - かな入力
    # - enable key repeat
  end

  task :jupyterlab do
    task if_err('which node'), 'brew install node'
    task if_err('jupyter lab --version'), 'pip install jupyterlab==2.2.9'
    task if_err('jupyter labextension list 2>&1 | grep @axlair/jupyterlab_vim'), 'jupyter labextension install @axlair/jupyterlab_vim'
    task if_err('jupyter labextension list 2>&1 | grep jupyterlab-vimrc'), 'jupyter labextension install jupyterlab-vimrc@0.3.0'
    task if_err('jupyter labextension list 2>&1 | grep jupyterlab_vim-system-clipboard-support'), 'jupyter labextension install jupyterlab_vim-system-clipboard-support'
    task if_err('jupyter labextension list 2>&1 | grep jupyterlab-plotly'), 'jupyter labextension install jupyterlab-plotly'
    task if_err('jupyter labextension list 2>&1 | grep variableinspector'), 'jupyter labextension install @lckr/jupyterlab_variableinspector'
    task symlink '~/.dotfiles/jupyter/user-settings', '~/.jupyter/lab/'
  end

  task :container_tools do
    task brew_cask 'virtualbox'
    task brew_cask 'vagrant'
    task brew_cask 'docker'
    task brew 'docker'
    task brew_cask_upgrade 'virtualbox'
    task brew_cask_upgrade 'vagrant'
    task brew_cask_upgrade 'docker'
    task brew_upgrade 'docker'

    task if_err('vagrant plugin list | grep vagrant-vbguest'), 'vagrant plugin install vagrant-vbguest'
  end

end

def brew(package)
  task_alias "install_#{package}_by_brew".to_sym, if_err("which #{package} || ls /usr/local/Cellar/#{package}"), "brew install #{package}"
end

def brew_upgrade(package)
  task_alias "upgrade_#{package}_by_brew".to_sym, "brew upgrade #{package}"
end

def brew_cask(package)
  task_alias "install_#{package}_by_cask".to_sym, if_not_exist("/usr/local/Caskroom/#{package}"), "brew cask install #{package}"
end

def brew_cask_upgrade(package)
  task_alias "update_#{package}_by_cask".to_sym, "brew upgrade --cask #{package}"
end

def mas(app_id)
  task_alias "install_#{app_id}_by_mas".to_sym, if_err("mas list | grep '^#{app_id} '"), "mas install #{app_id}"
end

def mas_upgrade(app_id)
  task_alias "upgrade_#{app_id}_by_mas".to_sym, "mas upgrade #{app_id}"
end

def symlink(origin, link)
  task_alias "symlink #{link} to #{origin}".to_sym, if_not_symlinked(origin, link), %(
                mkdir -p #{link.gsub(/[^\/]+\/?$/, '')}
                ln -si #{origin} #{link}
  )
end



