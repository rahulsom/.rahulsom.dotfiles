#SDK man and java
which sdk > /dev/null
if [ $? != 0 ]; then
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

installJava() {
    VERSION=$(sdk ls java | grep zulu | grep -v zulufx | cut -d \| -f 6 | grep $1 | head -1)
    INSTALLED=$(sdk ls java | grep $VERSION | grep -c installed)
    if [ $INSTALLED = 0 ]; then
        sdk install java $VERSION
    fi
}

installJava 8.0.