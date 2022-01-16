#!/bin/bash

#SDK man and java
if [ ! -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
  # This needs to be removed because we also have the sdkman.symlink in the adjacent directory.
  # This will remove the directory so installation can proceed.
  # The next run of `dotfiles_update` will sync that directory.
  if [ -d $HOME/.sdkman/ ]; then
    rm -rf $HOME/.sdkman/
  fi
  curl -s "https://get.sdkman.io" | bash
fi

source "$HOME/.sdkman/bin/sdkman-init.sh"

installJava() {
  VERSION=$(sdk ls java | grep " $1 " | cut -d \| -f 6 | grep $2 | head -1 | xargs echo)
  INSTALLED=$(sdk ls java | grep "$VERSION" | grep -c installed)
  if [ "$INSTALLED" = 0 ]; then
    sdk install java "$VERSION"
  fi
}

installLatest() {
  VERSION=$(sdk ls $1 | xargs -n 1 echo | grep -E '^[0-9.]+$' | sort --version-sort -r | head -1)
  if [ ! -d "$HOME/.sdkman/candidates/$1/$VERSION" ]; then
    sdk install "$1" "$VERSION"
  fi
}

installJava zulu 8.0.
installJava zulu 11.0.

installLatest groovy
installLatest visualvm
