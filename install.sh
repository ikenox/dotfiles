#!/bin/bash

DOTFILES_DIR=$HOME/repos/github.com/ikenox/dotfiles

if ! command -v ansible-playbook &> /dev/null
then
   /usr/bin/python3 -m pip install -U pip
   /usr/bin/python3 -m pip install --user ansible
else
  echo "skip: ansible is already installed"
fi

if ! command -v brew &> /dev/null
then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "skip: homebrew is already installed"
fi

if [ ! -e "$DOTFILES_DIR" ]; then
  git clone git@github.com:ikenox/dotfiles.git $DOTFILES_DIR
else
  echo "skip: git repository seems already exists to $DOTFILES_DIR"
fi

if [ ! -e "$DOTFILES_DIR/vars.yml" ]; then
  echo 'this-is: dummy-value' > $HOME/repos/github.com/ikenox/dotfiles/vars.yml
fi
