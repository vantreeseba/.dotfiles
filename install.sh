#!/bin/bash

if [ "$1" == "" ]; then
  echo put arg for dotfiles to install.
  echo -vim
  echo -awesome
fi

if [ "$1" == "-vim" ]; then
  echo symlinking vim/vimrc to ~/.vimrc;
  ln -rbfs vim/vimrc ~/.vimrc
fi

if [ "$1" == "-vim" ]; then
  echo symlinking awesome config: awesome to ~/.config/awesome;
  ln -rbfs awesome ~/.config/awesome
fi
