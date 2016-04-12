# karabiner
/Applications/Karabiner.app/Contents/Library/bin/karabiner export > karabiner.sh
cp ~/Library/Application\ Support/Karabiner/private.xml private.xml
echo "export karabiner settings file"

# homebrew
echo "ecport Brewfile"
brew brewdle dump --force --file=~/dotfiles/Brewfile

# pip
echo "export pip package lists"
pip freeze > ~/dotfiles/pip-packages
