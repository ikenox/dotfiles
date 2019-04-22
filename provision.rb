#!/usr/bin/env ruby

# todo debug mode
# todo dry-run mode
# todo cannot interrupt brew cask install

def run

  task :init do
    task :install_homebrew, do_if: has_err('which brew') do
      sh '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
    end

    task_brew 'git'
    task_symlink '~/.dotfiles/git/gitignore', '~/.gitignore'

    ghq_root = '~/repos'
    host = 'github.com'
    repo = 'ikenox/dotfiles'
    dotfiles_origin_dir = "#{ghq_root}/#{host}/#{repo}"
    task :clone_dotfiles, do_if: not_exist(dotfiles_origin_dir) do
      sh "git clone git@#{host}:#{repo}.git #{dotfiles_origin_dir}"
    end
    task_symlink dotfiles_origin_dir, '~/.dotfiles'
    task :gitconfig do
      sh 'cat ~/.dotfiles/git/gitconfig > ~/.gitconfig'
      sh "git config --global ghq.root #{ghq_root}"
    end

    task_brew 'ghq'
  end

  task :setup_git do
    task :set_username, do_if: has_err("git config user.name") do
      print "please type your git user.name: "
      name = gets.chomp
      sh "git config -f ~/.gitconfig.local user.name '#{name}'"
    end
    task :set_email, do_if: has_err("git config user.email") do
      print "please type your git user.email: "
      email = gets.chomp
      sh "git config -f ~/.gitconfig.local user.email '#{email}'"
    end
    task_brew 'ghq'
  end

  task :karabiner_elements do
    task_brew_cask 'karabiner-elements'
    # FIXME a little redundant
    task :karabiner_config, do_if: not_symlinked('~/.dotfiles/karabiner', '~/.config/karabiner') do
      task_symlink '~/.dotfiles/karabiner', '~/.config/karabiner'
    end
  end

  task :setup_vim do
    task_brew 'vim'
    task :install_vim_plug, do_if: not_exist("~/.vim/autoload/plug.vim") do
      sh "curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    end
    task_symlink '~/.dotfiles/vim/vimrc', '~/.vimrc'
    task_symlink '~/.dotfiles/vim/vimrc.keymap', '~/.vimrc.keymap'
  end

  task_brew 'peco'
  task_brew 'fzf'
  task_brew 'jq'
  task_brew 'mas'
  task :ag do
    task_brew 'the_silver_searcher'
    task_symlink '~/.dotfiles/ag/agignore', '~/.agignore'
  end

  task :fish do
    task_brew 'fish'
    task_symlink '~/.dotfiles/fish', '~/.config/fish'
    task :fisherman, do_if: not_exist('~/.config/fish/functions/fisher.fish') do
      sh 'curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher'
    end
    task :set_default_shell do
      task :add_shell, do_if: has_err("cat /etc/shells | grep $(which fish)") do
        sh "sudo bash -c 'echo $(which fish) >> /etc/shells'"
      end
      # task :add_shell, do_if: has_err("echo $SHELL | grep fish") do
      #   sh "sudo chsh -s $(which fish)"
      # end
    end
    sh 'fish -c "fisher"'

    task :jenv do
      task_brew 'jenv'
      task_symlink '~/.dotfiles/zsh/zshrc.module.jenv', '~/.zshrc.module.jenv'
    end
  end

  task :hyper do
    task_brew_cask 'hyper'
    task_symlink '~/.dotfiles/hyper/hyper.js', '~/.hyper.js'
  end

  task :osx_defaults do
    sh 'defaults write com.apple.dock autohide -bool true'
    sh 'defaults write com.apple.dock persistent-apps -array'
    sh 'defaults write com.apple.dock tilesize -int 55'
    sh 'defaults write com.apple.dock wvous-tl-corner -int 10'
    sh 'defaults write com.apple.dock wvous-tl-modifier -int 0'
    sh 'killall Dock'

    sh 'defaults write com.apple.finder AppleShowAllFiles YES'
    sh 'defaults write com.apple.finder NewWindowTarget -string "PfDe"'
    sh 'defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"'
    sh 'killall Finder'

    sh 'defaults write com.apple.Safari IncludeInternalDebugMenu -bool true'
    sh 'defaults write -g com.apple.trackpad.scaling 3'
  end

  task :vm do
    task_brew_cask 'virtualbox'
    task_brew_cask 'vagrant'
    task :vbguest, do_if: has_err('vagrant plugin list | grep vagrant-vbguest') do
      sh 'vagrant plugin install vagrant-vbguest'
    end
    task_brew 'docker'
    task_brew 'docker-machine'
    task_brew 'docker-compose'
  end

  task :intellij do
    task_brew_cask "jetbrains-toolbox"
    # task_brew_cask "intellij-idea"
    task_symlink '~/.dotfiles/intellij/ideavimrc', '~/.ideavimrc'
    # TODO apply settings.jar
  end

  task :jupyter do
    task_symlink '~/.dotfiles/jupyter/custom.js', '~/.jupyter/custom/custom.js'
  end

  task :python do
    task_symlink '~/.dotfiles/matplotlib/matplotlibrc', '~/.matplotlibrc'
    task :pyenv do
      task_brew 'pyenv'
      task_brew 'pyenv-virtualenv'
      task_symlink '~/.dotfiles/zsh/zshrc.module.pyenv', '~/.zshrc.module.pyenv'
    end
  end

  task :tap_brew_cask, do_if: has_err('brew tap | grep caskroom/cask') do
    sh 'brew tap caskroom/cask'
  end
  task_brew_cask 'slack'
  task_brew_cask 'alfred'
  task_brew_cask 'caffeine'
  task_brew_cask 'google-japanese-ime'
  task_brew_cask 'discord'

  task_mas 409183694 # keynote
  task_mas 409203825 # Numbers
  task_mas 409201541 # Pages
  task_mas 539883307 # LINE
  task_mas 409183694 # Keynote
  task_mas 485812721 # TweetDeck
  task_mas 405399194 # Kindle

  puts ""
  puts "[FINISHED]"
end

$level = -1

def task(name, do_if: true, &block)
  $level += 1

  print "    " * $level
  print "[TASK]: ", name, " "

  need_exec = do_if.respond_to?(:call) ? do_if.call : do_if

  if need_exec
    # TODO dont display when do_if is not specified
    puts "-> not provisioned"
    block.call
  elsif puts "-> already provisioned"
  end

  $level -= 1
end

# task aliases
def task_symlink(origin, link)
  task "put_symlink[#{link} -> #{origin}]", do_if: not_symlinked(origin, link) do
    sh "mkdir -p #{link.gsub(/[^\/]+\/?$/, '')}"
    sh "ln -s #{origin} #{link}"
  end
end

def task_brew(p, opt: "")
  # FIXME cannot detect the difference of option
  task "install_#{p}", do_if: not_exist("/usr/local/Cellar/#{p}") do
    sh "brew install #{p} #{opt}"
  end
end

def task_brew_cask(p)
  task "install_#{p}", do_if: not_exist("/usr/local/Caskroom/#{p}") do
    sh "brew cask install #{p}"
  end
end

def task_mas(app_id)
  task "install_app_#{app_id}", do_if: has_err("mas list | grep '^#{app_id} '") do
    sh "mas install #{app_id}"
  end
end

def not_symlinked(origin, link)
  current_link = `readlink #{link}`.chomp
  (origin.start_with? "~", "/") ?
      File.expand_path(origin) != current_link # absolute symlink
      : origin != current_link # relative symlink
end

def has_err(cmd)
  puts "> #{cmd}"
  system(cmd) === false
end

def not_exist(path)
  has_err "ls #{path}"
end

def sh(cmd)
  puts "> #{cmd}"
  system(cmd) or raise "command execution failed."
end

run
