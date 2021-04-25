#!/bin/bash

if test -z $1; then
  echo An argument for installation of config files is required. 
  echo -e 'Here are the available installs: \n'
  echo -all
  echo -vim
  echo -awesome
  echo -e ''
fi

# args for ln
# b makes a backup of the file if it exists already (prevent overwrites).
# r creates the symlinks relative to link location. 
# f removes the existing files (after backup). 
# s make a symlink instead of a hardlink.

if test "$1" = "-all" || test "$1" = "-vim"; then
  echo symlinking vim/vimrc to ~/.vimrc;
  ln -rbfs vim/vimrc ~/.vimrc
fi

if test "$1" = "-all" || test "$1" = "-awesome"; then
  echo symlinking awesome config: awesome to ~/.config/awesome;
  ln -rbfs awesome ~/.config/awesome
fi
