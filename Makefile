DOTFILES_ROOT:=$(shell pwd)
OS := $(shell uname)

all: init

init: essentials tools

essentials: brew git zsh vim

# =========================================
# homebrew
# =========================================

brew:
ifeq ($(OS),Darwin)
	# install homebrew
	./brew.sh
	# install packages
	brew tap homebrew/bundle
	brew bundle
else
endif

# =========================================
# vim
# =========================================

vim: .workspace markdown ag fzf
	# install vim
ifeq ($(OS),Darwin)
	brew install vim --with-python3 --with-lua
else
	cd ~/.workspace
	sudo yum install -y gtk+-devel gtk2-devel ncurses-devel
	wget http://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2
	tar xvf vim-7.4.tar.bz2
	cd vim74
	./configure --enable-gui=yes --enable-multibyte --with-features=huge --disable-selinux --prefix=/usr/local --enable-rubyinterp --enable-xim --enable-fontset|grep gui
	rm -rf vim-7.4.tar.bz2 vim74
endif
	# plugin manager
	curl -fLo $@ --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	# config
	ln -si $(DOTFILES_ROOT)/vimrc ~/.vimrc
	ln -si $(DOTFILES_ROOT)/vimrc.keymap ~/.vimrc.keymap
	ln -si $(DOTFILES_ROOT)/vim ~/.vim
	ln -si $(DOTFILES_ROOT)/ideavimrc ~/.ideavimrc
	ln -si $(DOTFILES_ROOT)/xvimrc ~/.xvimrc

ag:
ifeq ($(OS),Darwin)
	brew install 'ag'
else
	sudo rpm -ivhF http://swiftsignal.com/packages/centos/6/x86_64/the-silver-searcher-0.13.1-1.el6.x86_64.rpm
endif
	ln -si $(DOTFILES_ROOT)/agignore ~/.agignore

markdown:
ifeq ($(OS),Darwin)
	brew install grip
	brew install markdown
else
	# TODO
endif

fzf: .workspace
ifeq ($(OS),Darwin)
	brew install fzf
else
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install
endif


# =========================================
# git
# =========================================

git:
ifeq ($(OS),Darwin)
	brew install git
else
	sudo yum -y install git
endif
	ln -si $(DOTFILES_ROOT)/gitconfig ~/.gitconfig
	ln -si $(DOTFILES_ROOT)/gitignore ~/.gitignore

# =========================================
# zsh
# =========================================

zsh: peco
	# install zsh
ifeq ($(OS),Darwin)
	brew install zsh
else
	sudo yum install -y zsh
endif
	# zplug
	curl -sL https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
	ln -si $(DOTFILES_ROOT)/zshrc ~/.zshrc
	cp $(DOTFILES_ROOT)/zshrc.local.template ~/.zshrc.local
	zsh -c -i 'zplug install'

peco: .workspace
ifeq ($(OS),Darwin)
	brew install 'peco'
else
	cd .workspace	
	wget https://github.com/peco/peco/releases/download/v0.3.3/peco_linux_amd64.tar.gz
	tar xzvf peco_linux_amd64.tar.gz
	mv peco_linux_amd64/peco ~/bin/peco
	rm -rf peco_linux_amd64.tar.gz peco_linux_amd64
endif

# =========================================
# tmux
# =========================================

tmux:
ifeq ($(OS),Darwin)
	brew install tmux
	brew install reattach-to-user-namespace
	ln -si $(DOTFILES_ROOT)/tmux.conf ~/.tmux.conf
	ln -si $(DOTFILES_ROOT)/.tmux ~/.tmux
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	echo "Please add your default shell to /etc/shells, and execute 'chsh -s /path/to/shell'"
endif

# =========================================
# tools
# =========================================

tools:
ifeq ($(OS),Darwin)
	# go
	brew install go
	brew install ghq
else
	sudo yum -y install go
endif

# =========================================
# optional
# =========================================

electron-apps:
	brew install nativefier
	nativefier --name "Google Calendar" "calendar.google.com" ~/Applications
	nativefier --name "Gmail" "mail.google.com" ~/Applications


vbox-vagrant:
	brew cask install virtualbox
	brew cask install vagrant
	vagrant plugin install vagrant-vbguest

plenv:
	brew install plenv
	brew install perl-build
	ln -si $(DOTFILES_ROOT)/zshrc.module.plenv ~/.zshrc.module.plenv

rust:
	# rsvm
	ln -si $(DOTFILES_ROOT)/zshrc.module.rust ~/.zshrc.module.rust
	cargo install --git https://github.com/phildawes/racer.git
	cargo install --git https://github.com/rust-lang-nursery/rustfmt
	ghq get https://github.com/rust-lang/rust

pyenv:
	brew install python
	brew install pyenv
	brew install pyenv-virtualenv
	ln -si $(DOTFILES_ROOT)/zshrc.module.pyenv ~/.zshrc.module.pyenv

rbenv:
	brew install ruby
	brew install ruby-build
	brew install rbenv
	brew install rbenv-gemset
	ln -si $(DOTFILES_ROOT)/zshrc.module.rbenv ~/.zshrc.module.rbenv

docker:
	brew cask install virtualbox
	brew install docker
	brew install docker-machine
	brew install docker-compose

mysql-conf:
	ln -si $(DOTFILES_ROOT)/editrc ~/.editrc

karabiner-elements:
	brew cask install karabiner-elements
	mkdir -p ~/.config/karabiner
	ln -si $(DOTFILES_ROOT)/karabiner.json ~/.config/karabiner/karabiner.json

jupyter:
	ln -si $(DOTFILES_ROOT)/jupyter_notebook_config.py ~/.jupyter/jupyter_notebook_config.py
	# vim
	mkdir -p $(jupyter --data-dir)/nbextensions
	cd $(jupyter --data-dir)/nbextensions; git clone https://github.com/lambdalisue/jupyter-vim-binding vim_binding
	ln -si $(DOTFILES_ROOT)/custom.js ~/.jupyter/custom/custom.js
	echo "notice: Please exec following commands in your python environment\n"
	echo "pip install jupyter_contrib_nbextensions\n"
	echo "jupyter contrib nbextension install --user\n"
	echo "jupyter nbextension enable vim_binding/vim_binding\n"

atom:
	brew cask install atom
	ln -si $(DOTFILES_ROOT)/.atom ~/.atom
	apm install --packages-file $(DOTFILES_ROOT)/.atom/packages.txt

# =========================================
# helper
# =========================================

.workspace:
	mkdir -p ~/.workspace

