#!/usr/bin/env ruby

# todo debug mode
# todo dry-run mode

def run
  task :install_homebrew, do_if: has_err("which brew") do
    sh '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
  end
  task :install_git, do_if: has_err("which git") do
    sh "brew install git"
  end
  task :install_ghq, do_if: has_err("which ghq") do
    sh "brew install ghq"
  end

  task :put_dotfiles_repo, do_if: not_exist("~/.dotfiles") do
    # todo read ghq root dir from gitconfig
    task :git_clone_dotfiles, do_if: not_exist("~/repo/github.com/ikenox/dotfiles") do
      sh "git clone git@github.com:ikenox/dotfiles.git ~/repo/github.com/ikenox/dotfiles"
    end
    task :symlink_dotfiles_dir do
      sh "ln -s ~/.dotfiles"
    end
  end

  task :hoge do
    task :fuga do

    end
    task :foo do

    end
  end

  # task :git, do_if: -> {
  #   has_err("which git")
  # } do
  #   puts "helloooo"
  # end

  # task :install_homebrew, do_if:has_err("which brew") {
  # }
  #
  # task :hoge, {}
  #
  # task :init do
  #   task :clone_dotfiles_repo, do_if:(1) {  }
  # end
  # task :git, do_if: has_err("which git") {sh "brew install git"}
  # task :ghq, do_if: has_err("which git") {sh "brew install ghq"}
  #
  # task :tap_brew_cask, do_if: has_err("brew cask") {sh "brew tap caskroom/cask"}
  #
  # task :peco, do_if: has_err("which peco") {sh "brew install peco"}
  # task :fzf, do_if: has_err("which peco") {sh "brew install peco"}


  # task_if has_err("/usr/local/Caskroom/slack") ->{}
  #
  # # brew
  # task_brew 'peco'
  # task_brew 'mas'
  # task_brew 'fzf'
  #
  # # cask
  # task_brew_cask('slack'),
  #     task_brew_cask('karabiner-elements'),
  #     task_brew_cask('alfred'),
  #     task_brew_cask('iterm2'),
  #     task_brew_cask('caffeine'),
  #     task_brew_cask('google-japanese-ime'),

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

run