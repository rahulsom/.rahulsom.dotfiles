mkdir -p "$HOME/Library/Script Libraries"
if [ ! -d "$HOME/Library/Script Libraries/Slack.scptd" ]; then
  git clone https://github.com/samknight/slack_applescript "$HOME/Library/Script Libraries/Slack.scptd"
else
  (cd "$HOME/Library/Script Libraries/Slack.scptd" && git pull)
fi
