all: install

vim/autoload/plug.vim:
	curl -fLo $@ --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

symlinks:
	script_dir=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
	vim_dir=${script_dir}/.vim
	ln -si ${script_dir}/.gitconfig ~/.gitconfig
	ln -si ${script_dir}/.gitignore ~/.gitignore
	ln -si ${vim_dir}/.vimrc ~/.vimrc
	ln -si ${vim_dir}/.vim ~/.vim
	ln -si ${script_dir}/.ideavimrc ~/.ideavimrc
	ln -si ${script_dir}/.zshrc ~/.zshrc
	ln -si ${script_dir}/.matplotlib/matplotlibrc ~/.matplotlib/matplotlibrc
	ln -si ${script_dir}/.config/pep8 ~/.config/pep8
	ln -si ${script_dir}/.latexmkrc ~/.latexmkrc
