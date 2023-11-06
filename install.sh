#!/bin/bash

DOTFILES_DIR=$HOME/repos/github.com/ikenox/dotfiles

if ! command -v ansible-playbook &> /dev/null
then
  python3 -m pip install --user ansible
fi

if [ ! -e "$DOTFILES_DIR" ]; then
  git clone https://github.com/ikenox/dotfiles.git $DOTFILES_DIR
else
  echo "skip: git repository seems already exists to $DOTFILES_DIR"
fi

if [ ! -e "$DOTFILES_DIR/vars.yml" ]; then
  echo '' > $HOME/repos/github.com/ikenox/dotfiles/vars.yml
fi
