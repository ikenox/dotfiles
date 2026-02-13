#!/bin/bash

DOTFILES_DIR=$HOME/repos/github.com/ikenox/dotfiles
if [ ! -e "$DOTFILES_DIR" ]; then
  git clone git@github.com:ikenox/dotfiles.git $DOTFILES_DIR
else
  echo "OK: git repository already exists to $DOTFILES_DIR"
fi

cd $DOTFILES_DIR

PATH=$PATH:/opt/homebrew/bin
if ! command -v brew &> /dev/null
then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "OK: homebrew is already installed"
fi

if ! command -v node &> /dev/null
then
  brew install node
  npm install
else
  echo "OK: node is already installed"
fi

node provisioner/src/main.ts $@
