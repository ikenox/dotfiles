DOTFILES_ROOT:=$(shell pwd)
OS := $(shell uname)

all: init

unix-fundamental-tools: symlinks yum-zsh zsh-init zplug vim 

init: symlinks homebrew zsh-init vim 

yum-zsh:
	sudo yum install -y zsh

homebrew: install-homebrew brew-packages

install-homebrew:
	./brew.sh

brew-packages:
	brew tap homebrew/bundle
	brew bundle

zsh-init: zshrc.myenv zplug zplug-packages

vim: vim/autoload/plug.vim
	ifeq $(OS) Darwin
	else
	sudo yum install -y gtk+-devel gtk2-devel ncurses-devel
	wget ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2
	tar xvf vim-7.4.tar.bz2
	cd vim74
	./configure --enable-gui=yes --enable-multibyte --with-features=huge --disable-selinux --prefix=/usr/local --enable-rubyinterp --enable-xim --enable-fontset|grep gui
	endif

vim/autoload/plug.vim:
	curl -fLo $@ --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

zplug:
	curl -sL https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

zplug-packages:
	zplug install

symlinks:
	ln -s $(DOTFILES_ROOT)/gitconfig ~/.gitconfig
	ln -s $(DOTFILES_ROOT)/gitignore ~/.gitignore
	ln -s $(DOTFILES_ROOT)/vimrc ~/.vimrc
	ln -s $(DOTFILES_ROOT)/vimrc.keymap ~/.vimrc.keymap
	ln -s $(DOTFILES_ROOT)/vim ~/.vim
	ln -s $(DOTFILES_ROOT)/ideavimrc ~/.ideavimrc
	ln -s $(DOTFILES_ROOT)/xvimrc ~/.xvimrc
	ln -s $(DOTFILES_ROOT)/zshrc ~/.zshrc
	ln -s $(DOTFILES_ROOT)/zshrc.myenv ~/.zshrc.myenv
#	ln -s $(DOTFILES_ROOT)/matplotlib/matplotlibrc ~/.matplotlib/matplotlibrc
#	ln -s $(DOTFILES_ROOT)/latexmkrc ~/.latexmkrc

zshrc.myenv:
	cp $(DOTFILES_ROOT)/zshrc.myenv.template $(DOTFILES_ROOT)/zshrc.myenv

vbox-vagrant:
	brew cask install virtualbox
	brew cask install vagrant
	vagrant plugin install vagrant-vbguest

plenv:
	brew install plenv
	brew install perl-build

rbenv:
	brew install python
	brew install pyenv
	brew install pyenv-virtualenv

pyenv:
	brew install ruby
	brew install ruby-build
	brew install rbenv
	brew install rbenv-gemset

docker:
	brew cask install virtualbox
	brew install docker
	brew install docker-machine
	brew install docker-compose

