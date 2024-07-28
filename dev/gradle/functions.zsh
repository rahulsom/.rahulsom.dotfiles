gradle_prepare_computer_for_release() {
  # Say hello to 1password
  eval "$(op signin)"

  # Get the good stuff from 1password
  ORG_GRADLE_PROJECT_SONATYPEUSERNAME=$(op item get --format json issues.sonatype.org | jq -r '.fields[] | select(.id == "username") | .value')
  ORG_GRADLE_PROJECT_SONATYPEPASSWORD=$(op item get --format json issues.sonatype.org | jq -r '.fields[] | select(.id == "password") | .value')
  ORG_GRADLE_PROJECT_SIGNINGKEY=$(op item get --format json gpg.key | jq -r '.fields[] | select(.id == "notesPlain") | .value')
  ORG_GRADLE_PROJECT_SIGNINGPASSWORD=$(op item get --format json gpg.key | jq -r '.fields[] | select(.id == "password") | .value')
  GRGIT_USER=$(op item get --format json github.com | jq -r '.fields[] | select (.label == "token") | .value')

  export ORG_GRADLE_PROJECT_SONATYPEUSERNAME
  export ORG_GRADLE_PROJECT_SONATYPEPASSWORD
  export ORG_GRADLE_PROJECT_SIGNINGKEY
  export ORG_GRADLE_PROJECT_SIGNINGPASSWORD
  export GRGIT_USER
}

gradle_setup_github_secrets() {
  if [ "$ORG_GRADLE_PROJECT_SONATYPEPASSWORD" != "" ]; then
    # Load the stuff into github
    echo -n $ORG_GRADLE_PROJECT_SONATYPEUSERNAME | gh secret set ORG_GRADLE_PROJECT_SONATYPEUSERNAME
    echo -n $ORG_GRADLE_PROJECT_SONATYPEPASSWORD | gh secret set ORG_GRADLE_PROJECT_SONATYPEPASSWORD
    echo -n $ORG_GRADLE_PROJECT_SIGNINGKEY | gh secret set ORG_GRADLE_PROJECT_SIGNINGKEY
    echo -n $ORG_GRADLE_PROJECT_SIGNINGPASSWORD | gh secret set ORG_GRADLE_PROJECT_SIGNINGPASSWORD
    echo "Configured"
  else
    echo "Secrets not loaded"
  fi
}

gradle_clear_secrets() {
  # if you're done, clear the env vars
  unset ORG_GRADLE_PROJECT_SONATYPEUSERNAME
  unset ORG_GRADLE_PROJECT_SONATYPEPASSWORD
  unset ORG_GRADLE_PROJECT_SIGNINGKEY
  unset ORG_GRADLE_PROJECT_SIGNINGPASSWORD
  unset GRGIT_USER
}

gradle_isolate_env() {
  env -i HOME="$HOME" \
      ORG_GRADLE_PROJECT_SONATYPEUSERNAME="$ORG_GRADLE_PROJECT_SONATYPEUSERNAME" \
      ORG_GRADLE_PROJECT_SONATYPEPASSWORD="$ORG_GRADLE_PROJECT_SONATYPEPASSWORD" \
      ORG_GRADLE_PROJECT_SIGNINGKEY="$ORG_GRADLE_PROJECT_SIGNINGKEY" \
      ORG_GRADLE_PROJECT_SIGNINGPASSWORD="$ORG_GRADLE_PROJECT_SIGNINGPASSWORD" \
      GRGIT_USER="$GRGIT_USER" \
      JAVA_HOME="$JAVA_HOME" \
      PATH="$PATH" \
      ./gradlew "$@"
}
