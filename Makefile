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
	ln -si $(DOTFILES_ROOT)/zshrc ~/.zshrc
	ln -si $(DOTFILES_ROOT)/zshrc.myenv ~/.zshrc.myenv
#	ln -si $(DOTFILES_ROOT)/matplotlib/matplotlibrc ~/.matplotlib/matplotlibrc
#	ln -si $(DOTFILES_ROOT)/latexmkrc ~/.latexmkrc

karabiner:
	# if ! pgrep -q Karabiner; then
	#   sql="
	# 	INSERT OR REPLACE INTO access
	# 	VALUES('kTCCServiceAccessibility','org.pqrs.Karabiner-AXNotifier',0,1,0,NULL);
	#   "
	#   sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "${sql}"
	#   open -a Karabiner.app
	# fi
	# # /Applications/Karabiner.app/Contents/Library/bin/karabiner export > karabiner.sh
	# # を事前にしておく
	# source karabiner.sh
	# cp private.xml ~/Library/Application\ Support/Karabiner/private.xml
	# echo "set karabiner settings"
	#
	
zshrc.myenv:
	cp $(DOTFILES_ROOT)/zshrc.myenv.template $(DOTFILES_ROOT)/zshrc.myenv
