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

_github_repo_status() {
  local repo_path=$1
  if [ ! -d "$repo_path/.git" ]; then
    return
  fi
  (
    cd "$repo_path" || exit

    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    local reset=$'\e[0m'
    local blue=$'\e[34m'
    local green=$'\e[32m'
    local red=$'\e[31m'
    local yellow=$'\e[33m'

    local branch_display="${branch}"
    if [[ "$branch" != "main" && "$branch" != "master" ]]; then
      branch_display="${blue}${branch}${reset}"
    fi

    # Find default remote branch
    local sync_branch
    local head_ref=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null)
    if [ -n "$head_ref" ]; then
      sync_branch="origin/${head_ref##*/}"
    elif git rev-parse --verify origin/main >/dev/null 2>&1; then
      sync_branch="origin/main"
    elif git rev-parse --verify origin/master >/dev/null 2>&1; then
      sync_branch="origin/master"
    fi

    local ab=""
    if [ -n "$sync_branch" ]; then
      local counts=$(git rev-list --left-right --count HEAD...$sync_branch 2>/dev/null)
      if [ -n "$counts" ]; then
        local ahead=$(echo $counts | awk '{print $1}')
        local behind=$(echo $counts | awk '{print $2}')
        if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
          ab=" ${green}+${ahead}${reset} ${red}-${behind}${reset}"
        elif [ "$ahead" -gt 0 ]; then
          ab=" ${green}+${ahead}${reset}"
        elif [ "$behind" -gt 0 ]; then
          ab=" ${red}-${behind}${reset}"
        fi
      fi
    fi

    local dirty=""
    local changes=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
    if [ "$changes" -gt 0 ]; then
      if [ "$changes" -eq 1 ]; then
        dirty=" ${yellow}(1 change)${reset}"
      else
        dirty=" ${yellow}($changes changes)${reset}"
      fi
    fi

    echo "[${branch_display}${ab}]${dirty}"
  )
}

github_tree() {
  local base="${HOME}/src/gh"
  local current_dir=$(pwd)
  echo "$base"
  local orgs=()
  for d in "$base"/*; do
    [ -d "$d" ] && orgs+=("$d")
  done
  local org_count=${#orgs[@]}
  local org_i=0

  for org in "${orgs[@]}"; do
    org_i=$((org_i + 1))
    local org_name=$(basename "$org")
    local org_prefix="├──"
    local repo_indent="│  "
    if [ $org_i -eq $org_count ]; then
      org_prefix="└──"
      repo_indent="    "
    fi
    echo "$org_prefix $org_name"

    local repos=()
    for d in "$org"/*; do
      [ -d "$d" ] && repos+=("$d")
    done
    local repo_count=${#repos[@]}
    local repo_i=0
    for repo in "${repos[@]}"; do
      repo_i=$((repo_i + 1))
      local repo_status=$(_github_repo_status "$repo")
      local repo_prefix="├──"
      if [ $repo_i -eq $repo_count ]; then
        repo_prefix="└──"
      fi
      local repo_name=$(basename "$repo")
      if [ -n "$repo_status" ]; then
        echo "$repo_indent $repo_prefix $repo_name $repo_status"
      else
        echo "$repo_indent $repo_prefix $repo_name"
      fi
    done
  done
  cd "$current_dir"
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
