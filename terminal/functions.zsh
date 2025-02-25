#!/usr/bin/env bash

# Create a new directory and enter it
function mkd() {
	mkdir -p "$@" && cd "$_";
}

# Change working directory to the top-most Finder window location
function cdf() { # short for `cdfinder`
	cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')";
}

# Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
function targz() {
	local tmpFile="${@%/}.tar";
	tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1;

	size=$(
		stat -f"%z" "${tmpFile}" 2> /dev/null; # macOS `stat`
		stat -c"%s" "${tmpFile}" 2> /dev/null;  # GNU `stat`
	);

	local cmd="";
	if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
		# the .tar file is smaller than 50 MB and Zopfli is available; use it
		cmd="zopfli";
	else
		if hash pigz 2> /dev/null; then
			cmd="pigz";
		else
			cmd="gzip";
		fi;
	fi;

	echo "Compressing .tar ($((size / 1000)) kB) using \`${cmd}\`…";
	"${cmd}" -v "${tmpFile}" || return 1;
	[ -f "${tmpFile}" ] && rm "${tmpFile}";

	zippedSize=$(
		stat -f"%z" "${tmpFile}.gz" 2> /dev/null; # macOS `stat`
		stat -c"%s" "${tmpFile}.gz" 2> /dev/null; # GNU `stat`
	);

	echo "${tmpFile}.gz ($((zippedSize / 1000)) kB) created successfully.";
}

# Determine size of a file or total size of a directory
function fs() {
	if du -b /dev/null > /dev/null 2>&1; then
		local arg=-sbh;
	else
		local arg=-sh;
	fi
	if [[ -n "$@" ]]; then
		du $arg -- "$@";
	else
		du $arg .[^.]* ./*;
	fi;
}

# Use Git’s colored diff when available
hash git &>/dev/null;
if [ $? -eq 0 ]; then
	function diff() {
		git diff --no-index --color-words "$@";
	}
fi;

# Create a data URL from a file
function dataurl() {
	local mimeType=$(file -b --mime-type "$1");
	if [[ $mimeType == text/* ]]; then
		mimeType="${mimeType};charset=utf-8";
	fi
	echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
}

# Create a git.io short URL
function gitio() {
	if [ -z "${1}" -o -z "${2}" ]; then
		echo "Usage: \`gitio slug url\`";
		return 1;
	fi;
	curl -i https://git.io/ -F "url=${2}" -F "code=${1}";
}

# Start a PHP server from a directory, optionally specifying the port
# (Requires PHP 5.4.0+.)
function phpserver() {
	local port="${1:-4000}";
	local ip=$(ipconfig getifaddr en1);
	sleep 1 && open "http://${ip}:${port}/" &
	php -S "${ip}:${port}";
}

# Compare original and gzipped file size
function gz() {
	local origsize=$(wc -c < "$1");
	local gzipsize=$(gzip -c "$1" | wc -c);
	local ratio=$(echo "$gzipsize * 100 / $origsize" | bc -l);
	printf "orig: %d bytes\n" "$origsize";
	printf "gzip: %d bytes (%2.2f%%)\n" "$gzipsize" "$ratio";
}

# Syntax-highlight JSON strings or files
# Usage: `json '{"foo":42}'` or `echo '{"foo":42}' | json`
function json() {
	if [ -t 0 ]; then # argument
		python -mjson.tool <<< "$*" | pygmentize -l javascript;
	else # pipe
		python -mjson.tool | pygmentize -l javascript;
	fi;
}

# Run `dig` and display the most useful info
function digga() {
	dig +nocmd "$1" any +multiline +noall +answer;
}

# UTF-8-encode a string of Unicode symbols
function escape() {
	printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u);
	# print a newline unless we’re piping the output to another program
	if [ -t 1 ]; then
		echo ""; # newline
	fi;
}

# Decode \x{ABCD}-style Unicode escape sequences
function unidecode() {
	perl -e "binmode(STDOUT, ':utf8'); print \"$@\"";
	# print a newline unless we’re piping the output to another program
	if [ -t 1 ]; then
		echo ""; # newline
	fi;
}

# Get a character’s Unicode code point
function codepoint() {
	perl -e "use utf8; print sprintf('U+%04X', ord(\"$@\"))";
	# print a newline unless we’re piping the output to another program
	if [ -t 1 ]; then
		echo ""; # newline
	fi;
}

# Show all the names (CNs and SANs) listed in the SSL certificate
# for a given domain
function getcertnames() {
	if [ -z "${1}" ]; then
		echo "ERROR: No domain specified.";
		return 1;
	fi;

	local domain="${1}";
	echo "Testing ${domain}…";
	echo ""; # newline

	local tmp=$(echo -e "GET / HTTP/1.0\nEOT" \
		| openssl s_client -connect "${domain}:443" -servername "${domain}" 2>&1);

	if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
		local certText=$(echo "${tmp}" \
			| openssl x509 -text -certopt "no_aux, no_header, no_issuer, no_pubkey, \
			no_serial, no_sigdump, no_signame, no_validity, no_version");
		echo "Common Name:";
		echo ""; # newline
		echo "${certText}" | grep "Subject:" | sed -e "s/^.*CN=//" | sed -e "s/\/emailAddress=.*//";
		echo ""; # newline
		echo "Subject Alternative Name(s):";
		echo ""; # newline
		echo "${certText}" | grep -A 1 "Subject Alternative Name:" \
			| sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2;
		return 0;
	else
		echo "ERROR: Certificate not found.";
		return 1;
	fi;
}

# `v` with no arguments opens the current directory in Vim, otherwise opens the
# given location
function v() {
	if [ $# -eq 0 ]; then
		vim .;
	else
		vim "$@";
	fi;
}

# `o` with no arguments opens the current directory, otherwise opens the given
# location
function o() {
	if [ $# -eq 0 ]; then
		open .;
	else
		open "$@";
	fi;
}

# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
function tre() {
	tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
}

function gw() {
    if [ -f ./grailsw ]; then
        ./grailsw "$@"
    elif [ -f ./gradlew ]; then
        ./gradlew "$@"
    else
        echo "Wrong directory to run gw!"
    fi
}

function gwo() {
    JAVA_OPTS="-server -Xmx2048M -Xms2048M -XX:PermSize=256m -XX:MaxPermSize=256m -Dfile.encoding=UTF-8" gw "$@"
}

function rmgrape() {
    GRAPEDIR=~/.groovy/grapes/$1
    M2DIR=~/.m2/repository/$(echo $1 | sed -e"s/\\./\//g")

    rm -rf $GRAPEDIR $M2DIR
}

countdown(){
    date1=$((`date +%s` + $1));
    while [ "$date1" -ge `date +%s` ]; do
        echo -n "  $(($date1 - `date +%s`)) seconds left      \r"
        sleep 0.1
    done
    echo ""
}

function orly() {
    ANIMAL=$(( ( RANDOM % 40 )  + 1 ))
    COLOR=$(( ( RANDOM % 17 )  + 0 ))
    FILE=$(echo $ANIMAL-$COLOR-$1-$2-$3 | md5)
    if [ "$1" = "" ]; then
        echo "Need a title"
    elif [ "$2" = "" ]; then
        echo "Need a top text"
    elif [ "$3" = "" ]; then
        echo "Need an author"
    else
        http GET http://orly-appstore.herokuapp.com/generate \
                title=="$1" \
                top_text=="$2" \
                author=="$3" \
                image_code==$ANIMAL \
                theme==$COLOR \
                guide_text=='The definitive guide' \
                guide_text_placement=='bottom_right' \
                Referer:'http://dev.to/rly' > $FILE.png
        echo "$FILE.png"
    fi
}

# DropUntil and TakeBefore for text files.
function sedDropUntil() {
    sed -n "/$1/,\$p" $2
}
function sedTakeBefore() {
    sed -n "/^$1/q;p" $2
}

# Sometimes you need corporate certs in your default JKS
function installCorpCertInJKS() {
    if [ "$CORP_CERT_ALIAS" != "" ]; then
        if [ "$CORP_CERT" != "" ]; then
            CERTS_FILE="${JAVA_HOME}/jre/lib/security/cacerts"
            echo "CERTS_FILE = $CERTS_FILE"
            curl -s "$CORP_CERT" > /tmp/corpcert.crt
            if [ -f "${CERTS_FILE}" ]; then
                echo "Found cacerts file"
                if [ -f "${CERTS_FILE}.orig" ]; then
                    echo "Backing up exists"
                else
                    echo "Backing up file"
                    sudo cp "$CERTS_FILE" "${CERTS_FILE}.orig"
                fi
                sudo keytool -import -trustcacerts \
                        -alias "$CORP_CERT_ALIAS" \
                        -storepass changeit \
                        -file /tmp/corpcert.crt \
                        -keystore "$CERTS_FILE"
            else
                echo "Could not find cacerts at $CERTS_FILE"
            fi
        else
            echo "Please define CORP_CERT"
        fi
    else
        echo "Please define CORP_CERT_ALIAS"
    fi
}

# Restart audio daemon when there's no sound in MacOS
function restart_audio() {
    command sudo killall coreaudiod && \
    sudo launchctl unload /System/Library/LaunchDaemons/com.apple.audio.coreaudiod.plist && \
    sudo launchctl   load /System/Library/LaunchDaemons/com.apple.audio.coreaudiod.plist || \
    return
    echo 'Audio daemon restarted'
}

function whichwifi() {
  /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}'
}

function gwdi() {
	if [ "$1" = "" ]; then
		cat << EOF
gwdi - gradlew dependency insight

Usage:
gwdi <dependency> [configuration [subproject]]

Example:
gwdi reactive-streams
gwdi reactive-streams compileClasspath
gwdi reactive-streams compileClasspath grooves-java

EOF
	elif [ "$2" = "" ]; then
		./gradlew dependencyInsight --dependency $1
	elif [ "$3" = "" ]; then
		./gradlew dependencyInsight --dependency $1 --configuration $2
	else
		./gradlew :$3:dependencyInsight --dependency $1 --configuration $2
	fi

}

function init_editorconfig() {
  INDENT=${1:-2}
  CONTINUATION=$(($INDENT * 2))
  cat > .editorconfig << EOF
[*]
charset=utf-8
end_of_line=lf
insert_final_newline=false
indent_style=space
indent_size=$INDENT
continuation_indent_size=$CONTINUATION
ij_continuation_indent_size=$CONTINUATION
EOF
}

function agr { ag -0 -l "$1" | xargs -0 perl -pi.bak -e "s/$1/$2/g"; }

function take() {
  local n=$1
  awk "NR <= $n"
}

function drop() {
  local n=$1
  awk "NR > $n"
}

function dropLast() {
  local n=$1
  ghead -n -${n}
}

function takeLast() {
  local n=$1
  gtail -n ${n}
}
