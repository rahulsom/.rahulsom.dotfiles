function _idealog() {
  compadd -- $(find $HOME/Library/Logs -name idea.log | sort | sed -e "s/.*Logs\///g" | sed -e "s/\/idea.log//g")
}
compdef _idealog idealog
