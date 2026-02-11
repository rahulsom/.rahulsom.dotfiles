github_help() {
  echo "Usage: github <subcommand> [options]"
  echo ""
  echo "Subcommands:"
  echo "    browse   Open a GitHub project page in the default browser"
  echo "    cd       Go to the directory of the specified repository"
  echo "    tree     Print tree of github repositories"
  echo ""
  echo "For help with each subcommand run:"
  echo "github <subcommand> -h|--help"
  echo ""
}

github_cd() {
	if [ "$(echo $1 | grep -c /)" = "1" ]; then
		ORG=$(echo "$1" | cut -d / -f 1)
		REPO=$(echo "$1" | cut -d / -f 2)

		mkdir -p "${HOME}/src/gh/${ORG}"
		cd "${HOME}/src/gh/${ORG}" || return
		if [ ! -d "${REPO}" ]; then
			git clone --recursive "git@github.com:${ORG}/${REPO}" "$HOME/src/gh/${ORG}/${REPO}" || return
		fi
		cd "${HOME}/src/gh/${ORG}/${REPO}" || return
  fi
}

github_browse() {
	open "$(git remote -v | awk '/fetch/{print $2}' | sed -Ee 's#(git@|git://)#http://#' -e 's@com:@com/@')" | head -n1
}

github() {
  subcommand=$1
  case $subcommand in
  "" | "-h" | "--help")
    github_help
    ;;
  *)
    shift
    "github_${subcommand}" "$@"
    if [ $? = 127 ]; then
      echo "Error: '$subcommand' is not a known subcommand." >&2
      echo "       Run 'github --help' for a list of known subcommands." >&2
      return 1
    fi
    ;;
  esac
}
