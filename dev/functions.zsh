#!/bin/zsh

function generatePassword() {
  local LENGTH=${1:-9}
  local SETS=${2:-aA0}
  groovy -e "
    def generator = { String alphabet, int n ->
      new java.security.SecureRandom().with {
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

function _run_npx() {
  local package=$1
  local version_var=$2
  shift 2
  local version="${(P)version_var:-latest}"
  npx --yes "${package}@${version}" "$@"
}

function gemini() {
  _run_npx @google/gemini-cli GEMINI_VERSION "$@"
}

function jules() {
  _run_npx @google/jules JULES_VERSION "$@"
}

function qwen() {
  _run_npx @qwen-code/qwen-code QWEN_VERSION "$@"
}

function copilot() {
  _run_npx @github/copilot COPILOT_VERSION "$@"
}

function opencode() {
  _run_npx opencode-ai OPENCODE_VERSION "$@"
}

function jq_sort() {
  jq 'def sortkeys: . as $in | if type == "object" then to_entries | sort_by(.key) | map({(.key): (.value|sortkeys)}) | add elif type == "array" then map(sortkeys) else . end; sortkeys' "$@"
}

function coco() {
  "$@" > >(while IFS= read -r line; do
    print -P -- "%F{blue} ┃%f $line"
  done) 2> >(while IFS= read -r line; do
    print -P -- "%F{red} ┃%f $line" >&2
  done)
}
