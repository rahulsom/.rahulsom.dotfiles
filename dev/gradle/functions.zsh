gradle_prepare_computer_for_release() {
  # Say hello to 1password
  eval $(op signin my)

  # Get the good stuff from 1password
  export ORG_GRADLE_PROJECT_sonatypeUsername=$(op get item issues.sonatype.org | jq -r '.details.fields[] | select(.name == "username") | .value')
  export ORG_GRADLE_PROJECT_sonatypePassword=$(op get item issues.sonatype.org | jq -r '.details.fields[] | select(.name == "password") | .value')
  export ORG_GRADLE_PROJECT_signingKey=$(op get item gpg.key | jq -r '.details.notesPlain')
  export ORG_GRADLE_PROJECT_signingPassword=$(op get item gpg.key | jq -r '.details.fields[] | select(.name == "password") | .value')
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
