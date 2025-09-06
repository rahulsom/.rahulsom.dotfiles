#!/bin/zsh

function generatePassword() {
  local LENGTH=${1:-9}
  local SETS=${2:-aA0}
  groovy -e "
    def generator = { String alphabet, int n ->
      new Random().with {
        (1..n).collect { alphabet[ nextInt( alphabet.length() ) ] }.join()
      }
    }

    def chars = ('a'..'a') - 'a'
    if ('$SETS'.contains('a')) { chars += ('a'..'z') }
    if ('$SETS'.contains('A')) { chars += ('A'..'Z') }
    if ('$SETS'.contains('0')) { chars += ('0'..'9') }

    def charset = chars.join()
    if ('$SETS'.contains('.')) { charset += '!@#$%^&*-+=.?<>,/;~' }

    println generator(charset, $LENGTH )
  "
}

function gemini() {
  npx @google/gemini-cli@"${GEMINI_VERSION:-latest}" "$@"
}
