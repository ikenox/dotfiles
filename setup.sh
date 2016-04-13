# symlink ~/.* to dotfiles/.*
IFS=$'\n'

script_dir=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

ln -si ${script_dir}/.vimrc ~/.vimrc
ln -si ${script_dir}/.ideavimrc ~/.ideavimrc
ln -si ${script_dir}/.zshrc ~/.zshrc
ln -si ${script_dir}/.matplotlib/matplotlibrc ~/.matplotlib/matplotlibrc
ln -si ${script_dir}/.config/pep8 ~/.config/pep8

# karabiner
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

# homebrew
function confirm {
  MSG=$1
  while :
  do
    echo -n "${MSG} [Y/N]: "
    read ans
    case $ans in
    [yY]) return 0 ;;
    [nN]) return 1 ;;
    esac
  done
}

echo "install brew formula?[y/n]"
read answer
if [ "$answer" == "y" ]; then
  brew brewdle --file=~/dotfiles/Brewfile
　exit;
fi

#pip
echo "install pip packages?[y/n]"
read answer
if [ "$answer" == "y" ]; then
  pip install -r ~/dotfiles/pip-packages
　exit;
fi

#gitのエディタをvimに変更
git config --global core.editor 'vim -c "set fenc=utf-8"'
