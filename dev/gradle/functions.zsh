gradle_prepare_computer_for_release() {
  # Say hello to 1password
  eval "$(op signin my)"

  # Get the good stuff from 1password
  ORG_GRADLE_PROJECT_sonatypeUsername=$(op get item issues.sonatype.org | jq -r '.details.fields[] | select(.name == "username") | .value')
  ORG_GRADLE_PROJECT_sonatypePassword=$(op get item issues.sonatype.org | jq -r '.details.fields[] | select(.name == "password") | .value')
  ORG_GRADLE_PROJECT_signingKey=$(op get item gpg.key | jq -r '.details.notesPlain')
  ORG_GRADLE_PROJECT_signingPassword=$(op get item gpg.key | jq -r '.details.fields[] | select(.name == "password") | .value')

  export ORG_GRADLE_PROJECT_sonatypeUsername
  export ORG_GRADLE_PROJECT_sonatypePassword
  export ORG_GRADLE_PROJECT_signingKey
  export ORG_GRADLE_PROJECT_signingPassword
}

gradle_setup_github_secrets() {
  if [ "$ORG_GRADLE_PROJECT_sonatypePassword" != "" ]; then
    # Load the stuff into github
    echo -n $ORG_GRADLE_PROJECT_sonatypePassword | gh secret set ORG_GRADLE_PROJECT_sonatypePassword
    echo -n $ORG_GRADLE_PROJECT_signingKey | gh secret set ORG_GRADLE_PROJECT_signingKey
    echo -n $ORG_GRADLE_PROJECT_signingPassword | gh secret set ORG_GRADLE_PROJECT_signingPassword
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
}