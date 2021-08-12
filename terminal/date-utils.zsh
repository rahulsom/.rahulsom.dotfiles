function epoch() {
  if [ "$1" = "" ]; then
    gdate +%s
  else
    gdate -d "$1" +%s
  fi
}

function iso8601() {
  if [ "$1" = "" ]; then
    gdate +"%Y-%M-%d %H:%m:%S %:z"
  else
    gdate -d "@$1" +"%Y-%M-%d %H:%m:%S %:z"
  fi
}

function iso8601Utc() {
  if [ "$1" = "" ]; then
    gdate --utc +"%Y-%M-%d %H:%m:%S %:z"
  else
    gdate --utc -d "@$1" +"%Y-%M-%d %H:%m:%S %:z"
  fi
}

