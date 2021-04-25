#!/bin/bash

if test -z $1; then
  echo An argument for installation of programs is required. 
  echo -e 'Here are the available installs: \n'
  echo -all
  echo -vim
  echo -e ''
fi

if test "$1" = "-all" || test "$1" = "-vim"; then
  # exists in mainline ubuntu apt repo.
  sudo apt install neovim;
fi

if test "$1" = "-all" || test "$1" = "-awesome"; then
  # exists in mainline ubuntu apt repo.
  sudo apt install awesome;
fi
