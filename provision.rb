#!/usr/bin/env ruby

# todo debug mode
# todo dry-run mode
# todo cannot interrupt brew cask install
require './provision-task'

tasks do
  task :foge do
    task :fuga do
      task :foo, "echo 'foo'"
      task :bar, "echo 'bar'"
    end
  end
end

raise "a"

tasks do

  task :default do
    task :init do
      task :install_homebrew, if_err('which brew'),
           '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
      task :tap_brew_cask, if_err('brew tap | grep caskroom/cask'), 'brew tap caskroom/cask'

      task brew 'git'
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
        task "git config -f ~/.gitconfig.local ghq.root #{ghq_root}"
      end
    end

    task :setup_git do
      task :set_username, if_err("git config user.name"), -> {
        print "please type your git user.name: "
        name = gets.chomp
        "git config -f ~/.gitconfig.local user.name '#{name}'"
      }
      task :set_email, if_err("git config user.email"), -> {
        print "please type your git user.email: "
        email = gets.chomp
        "git config -f ~/.gitconfig.local user.email '#{email}'"
      }
      task brew 'ghq'
    end

    task :karabiner_elements do
      task brew_cask 'karabiner-elements'
      task symlink '~/.dotfiles/karabiner', '~/.config/karabiner'
    end

    task :setup_vim do
      task brew 'vim'
      task :install_vim_plug, if_not_exist("~/.vim/autoload/plug.vim"),
           "curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
      task symlink '~/.dotfiles/vim/vimrc', '~/.vimrc'
      task symlink '~/.dotfiles/vim/vimrc.keymap', '~/.vimrc.keymap'
    end

    task brew 'peco'
    task brew 'fzf'
    task brew 'jq'
    task brew 'mas'
    task :ag do
      task brew 'the_silver_searcher'
      task symlink '~/.dotfiles/ag/agignore', '~/.agignore'
    end

    task :fish do
      task brew 'fish'
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
      task 'fish -c "fisher"'
    end

    task :hyper do
      task brew_cask 'hyper'
      task symlink '~/.dotfiles/hyper/hyper.js', '~/.hyper.js'
    end

    # todo: set keyboard -> 入力ソース -> ひらがな(google)
    task brew_cask 'google-japanese-ime'

    task :osx_defaults do
      task 'defaults write com.apple.dock autohide -bool true'
      task 'defaults write com.apple.dock persistent-apps -array'
      task 'defaults write com.apple.dock tilesize -int 55'
      task 'defaults write com.apple.dock wvous-bl-corner -int 10'
      task 'defaults write com.apple.dock wvous-bl-modifier -int 0'
      # todo killall if updated
      # killall Dock'

      task 'defaults write com.apple.finder AppleShowAllFiles YES'
      task 'defaults write com.apple.finder NewWindowTarget -string "PfDe"'
      task 'defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"'
      # todo killall if updated
      # killall Finder'

      task 'defaults write com.apple.Safari IncludeInternalDebugMenu -bool true'

      # todo needs restart
      task 'defaults write -g com.apple.trackpad.scaling -int 3'
      task 'defaults write -g InitialKeyRepeat -int 15'
      task 'defaults write -g KeyRepeat -int 2'
      task 'defaults -currentHost write -globalDomain com.apple.mouse.tapBehavior -int 1'
    end

    task :container_tools do
      task brew_cask 'virtualbox'
      task brew_cask 'vagrant'
      task if_err('vagrant plugin list | grep vagrant-vbguest'), 'vagrant plugin install vagrant-vbguest'
      task brew 'docker'
      task brew 'docker-machine'
      task brew 'docker-compose'
    end

    task :intellij do
      task brew_cask "jetbrains-toolbox"
      task symlink '~/.dotfiles/intellij/ideavimrc', '~/.ideavimrc'
      # TODO apply settings.jar
    end

    task :jupyter do
      task symlink '~/.dotfiles/jupyter/custom.js', '~/.jupyter/custom/custom.js'
    end

    task :python do
      task symlink '~/.dotfiles/matplotlib/matplotlibrc', '~/.matplotlibrc'
      task :pyenv do
        task brew 'pyenv'
        task brew 'pyenv-virtualenv'
        task symlink '~/.dotfiles/zsh/zshrc.module.pyenv', '~/.zshrc.module.pyenv'
      end
    end

    task :java do
      task brew 'jenv'
      task brew_cask 'java8'
      task 'echo "set PATH $HOME/.jenv/bin $PATH" > ~/.dotfiles/fish/conf.d/jenv.fish'
      task 'curl https://raw.githubusercontent.com/gcuisinier/jenv/master/fish/jenv.fish > ~/.config/fish/jenv.fish'
      task 'curl https://raw.githubusercontent.com/gcuisinier/jenv/master/fish/export.fish > ~/.config/fish/export.fish'
    end

    #task_brew_cask 'slack'
    task brew_cask 'alfred' # todo change hotkey from gui
    task brew_cask 'caffeine'
    task brew_cask 'discord'

    # tood need login app store
    task mas 409183694 # keynote
    task mas 409203825 # Numbers
    task mas 409201541 # Pages
    task mas 539883307 # LINE
    task mas 485812721 # TweetDeck
    task mas 405399194 # Kindle

    # todo macos
    # disable spotlight
    # かな入力
    # enable key repeat
    #
    # todo python
    # https://qiita.com/zreactor/items/c3fd04417e0d61af0afe
    # sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /
  end

  task :test do
    task :init do
      task :install_homebrew, if_err('which brew'), 'brew install hoge'
      task :install_homebrew, if_err('which brew'),
           '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
      task :install_homebrew, if_err('which brew'),
           '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
      task do
        task brew 'git'
      end

      task 'rm -rf foo/bar'
      task :hoge, 'rm -rf foo/bar'
      task :tap_brew_cask, if_not_exist('~/.foo'), 'brew tap caskroom/cask'

      task brew 'git'
      task brew 'git'

      task symlink '~/.dotfiles/git/gitignore', '~/.gitignore'
      task symlink '~/.dotfiles/git/gitignore', '~/.gitignore'
    end
  end
end
