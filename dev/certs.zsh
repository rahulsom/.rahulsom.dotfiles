getX509() {
  if [ "$1" = "" ]; then
    echo "Please provide HOST:PORT"
  else
    if [[ $1 =~ ^https:\\/\\/.+$ ]]; then
      HOSTPORT=$(echo $1 | sed -e "s/^https:\\/\\///g")
    else
      HOSTPORT=$1
    fi
    if [[ ! $HOSTPORT =~ ^.+\\:[0-9]+/?$ ]]; then
      HOSTPORT=$(echo "${HOSTPORT}:443")
    fi
    echo | openssl s_client -servername NAME -connect ${HOSTPORT} 2>/dev/null | \
      sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'
  fi
}

getSAN() {
  if [ "$1" = "" ]; then
    cat - | openssl x509 -text | grep "X509v3 Subject Alternative Name" -A 1 | tail -1 | tr -s " " | tr , '\n'
  else
    cat $1 | openssl x509 -text | grep "X509v3 Subject Alternative Name" -A 1 | tail -1 | tr -s " " | tr , '\n'
  fi
}
