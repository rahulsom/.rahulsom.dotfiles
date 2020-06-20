_github_users() {
  queryString=$1
  hub api graphql -f query="query FindUsersOrOrganizations {
    users:search(type:USER, query: \"$queryString\", first:10) {
      userCount
      nodes {
        ... on Organization {
          login
          name
        }
        ... on User {
          login
          name
        }
      }
    }
  }" | jq -r  '.data.users.nodes[] | "\(.login):\(if .name == null then .login else .name end)"' | sed -e 's/:null"/:"/g'
}

_github_currentUser() {
  hub api graphql -f query="query WhoAmI {
    viewer {
      login
      name
    }
  }" | jq -r  '.data.viewer | "\(.login):\(if .name == null then .login else .name end)"' | sed -e 's/:null"/:"/g'
}

_github_repos() {
  queryString="$1"
  hub api graphql -f query="query repos {
    repositories:search(type:REPOSITORY, query: \"$queryString\", first:10) {
      repositoryCount
      nodes {
        ... on Repository {
          nameWithOwner
          description
        }
      }
    }
  }" | jq -r  '.data.repositories.nodes[] | "\(.nameWithOwner):\(if .description == null then .nameWithOwner else .description end)"' | sed -e 's/:null"/:"/g'
}

_github() {
  case $CURRENT in
  2)
    local -a subcmds=('browse:Browse to a repo' 'cd:Go to a repo. Clone if not already present locally' 'tree:List currently checked out repos')
    _describe 'github' subcmds
    ;;
  3)
    case "${words[2]}" in
    cd)
      if [ "$(echo "${words[3]}" | wc -c)" -gt 1 ]; then
        if [ "$(echo "${words[3]}" | grep -c /)" -gt 0 ]; then
          local ORG=$(echo "${words[3]}" | cut -d / -f 1)
          local REPO=$(echo "${words[3]}" | cut -d / -f 2)
          local repos=("${(@f)$(_github_repos "user:$ORG $REPO")}")
          _describe 'cd' repos
        else
          local users=("${(@f)$(_github_users ${words[3]})}")
          _describe 'cd' users
        fi
      else
        local currentUser=("${(@f)$(_github_currentUser)}")
        _describe 'cd' currentUser
      fi
      ;;
    esac
    ;;
  esac
}

compdef _github github
