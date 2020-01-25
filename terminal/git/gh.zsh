gh_help() {
  echo "Usage: gh <subcommand> [options]\n"
  echo "Subcommands:"
  echo "    browse   Open a GitHub project page in the default browser"
  echo "    cd       Go to the directory of the specified repository"
  echo "    tree     Print tree of github repositories"
  echo ""
  echo "For help with each subcommand run:"
  echo "gh <subcommand> -h|--help"
  echo ""
}

gh_cd() {
  mkdir -p $HOME/src/gh/$1
  cd $HOME/src/gh/$1 || return
  if [ ! -d $2 ]; then
    git clone --recursive "gh:$1/$2" $HOME/src/gh/$1/$2
  fi
  cd $HOME/src/gh/$1/$2 || return
}

gh_tree() {
  tree -L 2 $HOME/src/gh
}

gh() {
  subcommand=$1
  case $subcommand in
  "" | "-h" | "--help")
    gh_help
    ;;
  *)
    shift
    gh_${subcommand} $@
    if [ $? = 127 ]; then
      echo "Error: '$subcommand' is not a known subcommand." >&2
      echo "       Run 'gh --help' for a list of known subcommands." >&2
      return 1
    fi
    ;;
  esac
}
