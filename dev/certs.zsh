getX509() {
  if [ "$1" = "" ]; then
    echo "Please provide HOST:PORT"
  else
    local input=$1

    # Initialize default port
    default_port=443

    # Extract host and port
    if [[ "$input" =~ ^(http|https):// ]]; then
        # If input is a URL, remove the scheme
        input="${input#*://}"
    fi

    # Remove any path after the host and port
    input="${input%%/*}"

    # Check if input contains a port
    if [[ "$input" =~ :[0-9]+$ ]]; then
        # Extract host and port
        host="${input%:*}"
        port="${input##*:}"
    else
        # No port specified, use default
        host="$input"
        port="$default_port"
    fi

    name=$host

    # Check if the host is an IPv6 address
    if [[ "$host" =~ : ]]; then
        # If it's an IPv6 address, ensure it's enclosed in square brackets
        if [[ "$host" != $$*$$ ]]; then
            host="[$host]"
        fi
    fi

    echo "Getting X509 certificate for '$host:$port' with SNI '$name'"

    echo | openssl s_client -servername $host -connect ${host}:${port} 2>/dev/null | \
        sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'
  fi
}

getSAN() {
  if [ "$1" = "" ]; then
    cat - | openssl x509 -text | grep "X509v3 Subject Alternative Name" -A 1 | tail -1 | tr -s " " | tr , '\n' | sort
  else
    cat $1 | openssl x509 -text | grep "X509v3 Subject Alternative Name" -A 1 | tail -1 | tr -s " " | tr , '\n' | sort
  fi
}
