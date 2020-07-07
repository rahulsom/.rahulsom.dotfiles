#!/bin/bash

if [ ! -d ~/.config/nvim/bundle/ ]; then
  mkdir -p ~/.config/nvim/bundle/
fi
if [ ! -d ~/.config/nvim/bundle/Vundle.vim ]; then
  ln -s ~/.vundle ~/.config/nvim/bundle/Vundle.vim
fi
if [ ! -f ~/.config/nvim/init.vim ]; then
  SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
  ln -s $SCRIPTPATH/init.vim ~/.config/nvim/init.vim
  nvim +PluginInstall +qall
fi
