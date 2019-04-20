#!/usr/bin/env ruby

# todo debug mode
# todo dry-run mode

def run
  task :install_homebrew, do_if: has_err('which brew') do
    sh '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
  end
  task :tap_brew_cask, do_if: has_err('brew tap | grep caskroom/cask') do
    sh 'brew tap caskroom/cask'
  end
  task :install_git, do_if: has_err('which git') do
    sh 'brew install git'
  end

  dotfiles_dir = '~/repo/github.com/ikenox/dotfiles'
  task :put_dotfiles_repo, do_if: !symlink_exists?(dotfiles_dir, "~/.dotfiles") do
    # todo read ghq root dir from gitconfig
    task :clone_dotfiles, do_if: not_exist(dotfiles_dir) do
      sh "git clone git@github.com:ikenox/dotfiles.git #{dotfiles_dir}"
    end
    task_symlink dotfiles_dir, "~/.dotfiles"
  end

  task_symlink '~/.dotfiles/git/gitconfig', '~/.gitconfig'

  task_brew 'peco'
  task_brew 'fzf'
  task_brew 'mas'
  task_brew 'jq'
  task_brew 'ghq'

  task_brew_cask 'slack'
  task_brew_cask 'karabiner-elements'
  task_brew_cask 'alfred'
  task_brew_cask 'iterm2'
  task_brew_cask 'caffeine'
  task_brew_cask 'google-japanese-ime'

  task_mas 409183694 # keynote
  task_mas 409203825 # Numbers
  task_mas 409201541 # Pages
  task_mas 539883307 # LINE
  task_mas 409183694 # Keynote
  task_mas 485812721 # TweetDeck
  task_mas 405399194 # Kindle

end

$level = -1

def task(name, do_if: true, &block)
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

# task aliases
def task_symlink(source, symlink_file)
  task "put_symlink[#{symlink_file} -> #{source}]", do_if: !symlink_exists?(source, symlink_file) do
    sh "ln -si  #{source} #{symlink_file}"
  end
end

def task_brew(p)
  task "install_#{p}", do_if: not_exist("/usr/local/Cellar/#{p}") do
    sh "brew install #{p}"
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

def symlink_exists?(origin_file, symlink_file)
  current_link = `readlink #{symlink_file}`.chomp
  (origin_file.start_with? "~", "/") ?
      File.expand_path(origin_file) == current_link # absolute symlink
      : origin_file == current_link # relative symlink
end

def has_err(cmd)
  puts "> #{cmd}"
  system cmd
  $? != 0
end

system "hofds"

def not_exist(path)
  has_err "ls #{path}"
end

def sh(cmd)
  puts "> #{cmd}"
  system cmd
  raise "command execution failed" if $? != 0
end

run