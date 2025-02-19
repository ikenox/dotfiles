#!/bin/bash

DOTFILES_DIR=$HOME/repos/github.com/ikenox/dotfiles
if [ ! -e "$DOTFILES_DIR" ]; then
  git clone git@github.com:ikenox/dotfiles.git $DOTFILES_DIR
else
  echo "skip: git repository already exists to $DOTFILES_DIR"
fi

if ! command -v brew &> /dev/null
then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "skip: homebrew is already installed"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

if ! command -v deno &> /dev/null
then
  brew install deno
else
  echo "skip: deno is already installed"
fi

cd $DOTFILES_DIR && deno run --allow-all provision.ts
