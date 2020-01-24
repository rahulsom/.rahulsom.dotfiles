#!/bin/bash

#SDK man and java
if [ ! -f $HOME/.sdkman/bin/sdkman-init.sh ]; then
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

installJava zulu 8.0.
installJava zulu 11.0.