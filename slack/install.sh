SCRIPT_DIR="$HOME/Library/Script Libraries"
SLACK_SCRIPT_DIR="${SCRIPT_DIR}/Slack.scptd"

mkdir -p "${SCRIPT_DIR}"
if [ ! -d "${SLACK_SCRIPT_DIR}" ]; then
  git clone https://github.com/samknight/slack_applescript "${SLACK_SCRIPT_DIR}"
else
  (cd "${SLACK_SCRIPT_DIR}" && git pull)
fi
