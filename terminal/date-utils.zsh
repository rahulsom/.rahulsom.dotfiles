date_from_epoch() {
  EPOCH=${1:-$(gdate +%s)}
  jo epoch="$EPOCH" \
    utc="$(_iso8601Utc "$EPOCH")" \
    local="$(_iso8601 "$EPOCH")" | jq .
}

function date_from_iso8601() {
  if [ "$1" = "" ]; then
    date_from_epoch "$(gdate +%s)"
  else
    date_from_epoch "$(gdate -d "$1" +%s)"
  fi
}

function _iso8601() {
  gdate -d "@$1" +"%Y-%m-%d %H:%M:%S%:z"
}

function _iso8601Utc() {
  gdate --utc -d "@$1" +"%Y-%m-%d %H:%M:%S%:z"
}
