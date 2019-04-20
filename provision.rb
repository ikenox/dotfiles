#!/usr/bin/env ruby

# todo debug mode
# todo dry-run mode

def run
  task 'install homebrew', do_if: has_err("which brew") do
    sh '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
  end
  task 'install brew cask', do_if: has_err("brew cask") do
    sh 'brew tap caskroom/cask'
  end
  task 'install git', do_if: has_err("which git") do
    sh "brew install git"
  end
  task 'put dotfiles repo', do_if: not_exist("~/.dotfiles") do
    # todo read ghq root dir from gitconfig
    task 'clone dotfiles repo', do_if: not_exist("~/repo/github.com/ikenox/dotfiles") do
      sh "git clone git@github.com:ikenox/dotfiles.git ~/repo/github.com/ikenox/dotfiles"
    end
    task 'symlink dotfiles' do
      sh "ln -si ~/.dotfiles"
    end
  end
  task 'put gitconfig', do_if: has_err("ls -la ~/.gitconfig | grep '-> ~/.dotfiles/git/gitconfig'") do
    sh 'ln -si ~/.gitconfig ~/.dotfiles/git/gitconfig'
  end

  end

  ['peco', 'fzf', 'mas', 'jq', 'ghq'].each do |p|
    task "install_#{p}", do_if: has_err("which #{p}") do sh "brew install #{p}"
  end

  ['slack', 'karabiner-elements', 'alfred', 'iterm2', 'caffeine', 'google-japanese-ime'].each do |p|
    task "install_#{p}", do_if: has_err("which #{p}") do sh "brew cask install #{p}"
  end

  # brew cask
      InstallHomeBrewCaskTask(),
      BrewCaskTask('slack'),
      BrewCaskTask('karabiner-elements'),
      BrewCaskTask('alfred'),
      BrewCaskTask('iterm2'),
      BrewCaskTask('caffeine'),
      BrewCaskTask('google-japanese-ime'),

  # mas
      MasTask(409183694),  # keynote
      MasTask(409203825),  # Numbers
      MasTask(409201541),  # Pages
      MasTask(539883307),  # LINE
      MasTask(409183694),  # Keynote
      MasTask(485812721),  # TweetDeck
      MasTask(405399194),  # Kindle
  task :hoge do
    task :fuga do

    end
    task :foo do

    end
  end

end

$level = -1

def task(name, do_if:true, &block)
  $level += 1

  print "    " * $level
  print "TASK: ", name, " "

  need_exec = do_if.respond_to?(:call) ? do_if.call : do_if

  if need_exec
    puts "-> not provisioned"
    block.call
  elsif puts "-> already provisioned"
  end

  $level -= 1
end

def has_err(cmd)
  result = system cmd
  !result
end

def not_exist(path)
  has_err("ls #{path}")
end

def sh(cmd)
  system cmd, exception: true
  nil
end

def

end

run