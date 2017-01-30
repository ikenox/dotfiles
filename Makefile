DOTFILES_ROOT:=$(shell pwd)

all: install

install: .vim/autoload/plug.vim symlinks

.vim/autoload/plug.vim:
	curl -fLo $@ --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

symlinks:
	ln -si $(DOTFILES_ROOT)/gitconfig ~/.gitconfig
	ln -si $(DOTFILES_ROOT)/gitignore ~/.gitignore
	ln -si $(DOTFILES_ROOT)/vimrc ~/.vimrc
	ln -si $(DOTFILES_ROOT)/vim ~/.vim
	ln -si $(DOTFILES_ROOT)/ideavimrc ~/.ideavimrc
	ln -si $(DOTFILES_ROOT)/zshrc ~/.zshrc
	ln -si $(DOTFILES_ROOT)/matplotlib/matplotlibrc ~/.matplotlib/matplotlibrc
	ln -si $(DOTFILES_ROOT)/latexmkrc ~/.latexmkrc

karabiner:
	if ! pgrep -q Karabiner; then
	  sql="
		INSERT OR REPLACE INTO access
		VALUES('kTCCServiceAccessibility','org.pqrs.Karabiner-AXNotifier',0,1,0,NULL);
	  "
	  sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "${sql}"
	  open -a Karabiner.app
	fi
	# /Applications/Karabiner.app/Contents/Library/bin/karabiner export > karabiner.sh
	# を事前にしておく
	source karabiner.sh
	cp private.xml ~/Library/Application\ Support/Karabiner/private.xml
	echo "set karabiner settings"
