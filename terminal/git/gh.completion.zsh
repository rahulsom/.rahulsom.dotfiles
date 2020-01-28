_users() {
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

_currentUser() {
  hub api graphql -f query="query WhoAmI {
    viewer {
      login
      name
    }
  }" | jq -r  '.data.viewer | "\(.login):\(if .name == null then .login else .name end)"' | sed -e 's/:null"/:"/g'
}

_repos() {
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

_gh() {
  case $CURRENT in
  2)
    local -a subcmds=('browse:Browse to a repo' 'cd:Go to a repo. Clone if not already present locally' 'tree:List currently checked out repos')
    _describe 'gh' subcmds
    ;;
  3)
    case "${words[2]}" in
    cd)
      if [ "$(echo "${words[3]}" | wc -c)" -gt 1 ]; then
        if [ "$(echo "${words[3]}" | grep -c /)" -gt 0 ]; then
          ORG=$(echo "${words[3]}" | cut -d / -f 1)
          REPO=$(echo "${words[3]}" | cut -d / -f 2)
          repos=("${(@f)$(_repos "user:$ORG $REPO")}")
          _describe 'cd' repos
        else
          users=("${(@f)$(_users ${words[3]})}")
          _describe 'cd' users
        fi
      else
        currentUser=("${(@f)$(_currentUser)}")
        _describe 'cd' currentUser
      fi
      ;;
    esac
    ;;
  esac
}

compdef _gh gh
