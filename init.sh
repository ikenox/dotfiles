#!/bin/sh

DOTFILES_REPO="github.com/ikenox/dotfiles"

which brew >/dev/null 2>&1
if [ $? -ne 0 ];
then
  echo "install homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

which python3 >/dev/null 2>&1
if [ $? -ne 0 ];
then
  echo "install python3"
  brew install python3
fi

which ansible >/dev/null 2>&1
if [ $? -ne 0 ];
then
  echo "install ansible"
  brew install ansible
fi

which git >/dev/null 2>&1
if [ $? -ne 0 ];
then
  echo "install git"
  brew install git
fi

which ghq >/dev/null 2>&1
if [ $? -ne 0 ];
then
  echo "install ghq"
  brew install ghq
fi

ls ~/.dotfiles >/dev/null 2>&1
if [ $? -ne 0 ];
then
  # clone repo to temporary directory
  git clone https://$DOTFILES_REPO /tmp/dotfiles
  # create temporary symlink
  ln -si /tmp/dotfiles ~/.dotfiles
  # set ghq config (contains a definition of ghq root repository)
  ln -si ~/.dotfiles/gitconfig ~/.gitconfig
  # move repo to ghq root
  GHQ_ROOT_DIR="$(ghq root)"
  DOTFILES_DIR=$GHQ_ROOT_DIR/$DOTFILES_REPO
  mkdir -p $DOTFILES_DIR/..
  mv /tmp/dotfiles $DOTFILES_DIR/..
  # update symlink
  ln -sf $DOTFILES_DIR ~/.dotfiles
fi
