function highlight() {
  declare -A fg_color_map
  fg_color_map[black]=30
  fg_color_map[red]=31
  fg_color_map[green]=32
  fg_color_map[yellow]=33
  fg_color_map[blue]=34
  fg_color_map[magenta]=35
  fg_color_map[cyan]=36

  fg_c=$(echo -e "\e[1;${fg_color_map[$1]}m")
  c_rs=$'\e[0m'
  gsed -uE s"/$2/$fg_c\0$c_rs/g"
}

function jr() {

  while test $# -gt 0; do
    case "$1" in
      -H)
        echo " "
        echo "jenkins-runner [options]"
        echo " "
        echo "options:"
        echo "-H                      show help for jr"
        echo "-h, --help              show brief help"
        echo "-df                     specify docker run flags to include"
        echo "                        example: -df ' -e TEST=VALUE -e TEST2=VALUE2'"
        echo " "
        echo "--bash                  bash into the container"
        echo "--heroku-auth           include HEROKU_AUTH_NETRC variable to properly mount the Heroku auth file"
        return 0
        ;;
      -df)
        shift
        if test $# -gt 0; then
          local DOCKER_FLAGS="${1}"
        fi
        shift
        ;;
      --bash)
        shift
        local BASH_CMD=(-it --entrypoint bash)
        ;;
      *)
        local DOCKER_ARGS=("$@")
        if [ "$1" != "" ]; then
          break
        fi
        if [ $# -le 1 ]; then
          break
        fi
        ;;
    esac
  done

  echo -ne "\e[1;34m"
  echo "BASH_CMD=${BASH_CMD}"
  echo "DOCKER_FLAGS=$DOCKER_FLAGS"
  echo "DOCKER_ARGS=${DOCKER_ARGS}"
  echo -ne "\e[1;0m"
  echo ""

  if [ "$DOCKER_FLAGS" != "" ]; then
    eval "set -- $DOCKER_FLAGS"
    local DOCKER_FLAGS_PARSED=("$@")
  fi

  COMMON_ARGS=(run --rm --privileged
    -v /var/run/docker.sock:/var/run/docker.sock
    -v "$(pwd)":/workspace
    -v "$(pwd)":/build
    -e "USER_HOME=$HOME"
    -e "USER_PWD=$PWD"
    "${DOCKER_FLAGS_PARSED[@]}")

  if [ ! -z "${BASH_CMD}" ]; then
    COMMON_ARGS+=("${BASH_CMD[@]}")
  fi

  COMMON_ARGS+=("jenkins/jenkinsfile-runner")

  if [ -z "${BASH_CMD}" ]; then
    docker "${COMMON_ARGS[@]}" \
      "${DOCKER_ARGS[@]}" | highlight black '\[Pipeline\].+' | highlight green 'Finished: SUCCESS' | highlight red 'Finished: FAILURE'
  else
    docker "${COMMON_ARGS[@]}"
  fi

}
