DOTFILES_ROOT:=$(shell pwd)

all: init

init: zshrc.myenv symlinks homebrew zsh vim 

homebrew: install-homebrew brew-packages

install-homebrew:
	./brew.sh

brew-packages:
	brew tap homebrew/bundle
	brew bundle

zsh: zshrc.myenv zplug zplug-packages

vim: vim/autoload/plug.vim

vim/autoload/plug.vim:
	curl -fLo $@ --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

zplug:
	curl -sL --proto-redir -all,https https://zplug.sh/installer | zsh

zplug-packages:
	zplug install

symlinks:
	ln -si $(DOTFILES_ROOT)/gitconfig ~/.gitconfig
	ln -si $(DOTFILES_ROOT)/gitignore ~/.gitignore
	ln -si $(DOTFILES_ROOT)/vimrc ~/.vimrc
	ln -si $(DOTFILES_ROOT)/vimrc.keymap ~/.vimrc.keymap
	ln -si $(DOTFILES_ROOT)/vim ~/.vim
	ln -si $(DOTFILES_ROOT)/ideavimrc ~/.ideavimrc
	ln -si $(DOTFILES_ROOT)/xvimrc ~/.xvimrc
	ln -si $(DOTFILES_ROOT)/zshrc ~/.zshrc
	ln -si $(DOTFILES_ROOT)/zshrc.myenv ~/.zshrc.myenv
#	ln -si $(DOTFILES_ROOT)/matplotlib/matplotlibrc ~/.matplotlib/matplotlibrc
#	ln -si $(DOTFILES_ROOT)/latexmkrc ~/.latexmkrc

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

