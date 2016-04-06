r symlink ~/.* to dotfiles/.*
IFS=$'\n'
dotfiles=(`cat ".dotfiles"`)
reporitory_root=`cd $(dirname $0); pwd`
for dotfile in ${dotfiles[@]}
do
  from="${repository_root}/${dotfile}"
  to="${HOME}/${dotfile}"
  ln -si $from $to
  echo "linked ${from}"
done
ln -si "${repository_root}/.vimrc" "${HOME}/.ideavimrc"

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

#gitのエディタをvimに変更
git config --global core.editor 'vim -c "set fenc=utf-8"'
