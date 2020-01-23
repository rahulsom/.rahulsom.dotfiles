#!/bin/bash -e

find $HOME/Library/Preferences -maxdepth 1 -name "Intelli*" > /tmp/intellij.txt
while read i; do
  mkdir -p $i/options
  if [ -f $i/options/ignore.xml ]; then
    if [ ! -L $i/options/ignore.xml ]; then
      rm $i/options/ignore.xml
      ln -s $HOME/.intellij-ignore.xml $i/options/ignore.xml
    else
      if [ "$(readlink $i/options/ignore.xml)" != "$HOME/.intellij-ignore.xml" ]; then
        rm $i/options/ignore.xml
        ln -s $HOME/.intellij-ignore.xml $i/options/ignore.xml
      fi
    fi
  else
    ln -s $HOME/.intellij-ignore.xml $i/options/ignore.xml
  fi
done </tmp/intellij.txt