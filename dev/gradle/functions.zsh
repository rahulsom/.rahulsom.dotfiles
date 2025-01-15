gradle_prepare_computer_for_release() {
  # Say hello to 1password
  eval "$(op signin)"

  # Get the good stuff from 1password
  ORG_GRADLE_PROJECT_sonatypeUsername=$(op item get --format json SonatypeToken | jq -r '.fields[] | select(.id == "username") | .value')
  ORG_GRADLE_PROJECT_sonatypePassword=$(op item get --format json SonatypeToken | jq -r '.fields[] | select(.id == "password") | .value')
  ORG_GRADLE_PROJECT_signingKey=$(op item get --format json gpg.key | jq -r '.fields[] | select(.id == "notesPlain") | .value')
  ORG_GRADLE_PROJECT_signingPassword=$(op item get --format json gpg.key | jq -r '.fields[] | select(.id == "password") | .value')
  GRGIT_USER=$(op item get --format json github.com | jq -r '.fields[] | select (.label == "token") | .value')

  export ORG_GRADLE_PROJECT_sonatypeUsername
  export ORG_GRADLE_PROJECT_sonatypePassword
  export ORG_GRADLE_PROJECT_signingKey
  export ORG_GRADLE_PROJECT_signingPassword
  export GRGIT_USER
}

gradle_setup_github_secrets() {
  if [ "$ORG_GRADLE_PROJECT_sonatypePassword" != "" ]; then
    # Load the stuff into github
    echo -n $ORG_GRADLE_PROJECT_sonatypeUsername | gh secret set ORG_GRADLE_PROJECT_SONATYPEUSERNAME
    echo -n $ORG_GRADLE_PROJECT_sonatypePassword | gh secret set ORG_GRADLE_PROJECT_SONATYPEPASSWORD
    echo -n $ORG_GRADLE_PROJECT_signingKey | gh secret set ORG_GRADLE_PROJECT_SIGNINGKEY
    echo -n $ORG_GRADLE_PROJECT_signingPassword | gh secret set ORG_GRADLE_PROJECT_SIGNINGPASSWORD
    echo "Configured"
  else
    echo "Secrets not loaded"
  fi
}

gradle_clear_secrets() {
  # if you're done, clear the env vars
  unset ORG_GRADLE_PROJECT_sonatypeUsername
  unset ORG_GRADLE_PROJECT_sonatypePassword
  unset ORG_GRADLE_PROJECT_signingKey
  unset ORG_GRADLE_PROJECT_signingPassword
  unset GRGIT_USER
}

gradle_isolate_env() {
  env -i HOME="$HOME" \
      ORG_GRADLE_PROJECT_sonatypeUsername="$ORG_GRADLE_PROJECT_sonatypeUsername" \
      ORG_GRADLE_PROJECT_sonatypePassword="$ORG_GRADLE_PROJECT_sonatypePassword" \
      ORG_GRADLE_PROJECT_signingKey="$ORG_GRADLE_PROJECT_signingKey" \
      ORG_GRADLE_PROJECT_signingPassword="$ORG_GRADLE_PROJECT_signingPassword" \
      GRGIT_USER="$GRGIT_USER" \
      JAVA_HOME="$JAVA_HOME" \
      PATH="$PATH" \
      ./gradlew "$@"
}
