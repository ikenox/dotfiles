# symlink ~/.* to dotfiles/.*
IFS=$'\n'
dotfiles=(`cat ".dotfiles"`)
for dotfile in ${dotfiles[@]}
do
  from="${repository_root}/${dotfile}"
  to="${HOME}/${dotfile}"
  ln -s $from $to
  echo "set ${from}"
done

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
