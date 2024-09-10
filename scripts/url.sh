#!/bin/bash

function url_is() {
echo DEBUG: function $FUNCNAME\("$1"\) 
	# ^([^:]\{1,\})://(.\{1,\})([^?#]\{0,\})([^?]\{0,\})([^#]\{0,\})
	if [[ "$1" =~ ([^:]+)://([^/]+)([^?#]*)(.*) ]] then
		URL_SCHEME="${BASH_REMATCH[1]}"
		local URL_DOMAIN_PORT="${BASH_REMATCH[2]}"
		URL_PATH_TO_FILE="${BASH_REMATCH[3]}"
		local PARAMETER_ANCHOR="${BASH_REMATCH[4]}"
		if [[ "$DOMAIN_PORT" =~ ([^:]+):(.+) ]] then
			URL_DOMAIN="${BASH_REMATCH[1]}"
			URL_PORT="${BASH_REMATCH[2]}"
		else
			URL_DOMAIN=$DOMAIN_PORT
			URL_PORT="(default)"
		fi
		if [[ "$PARAMETER_ANCHOR" =~ \?([^#]+) ]] then
			URL_PARAMETER="${BASH_REMATCH[1]}"
		else
			URL_PARAMETER=""
		fi
		
		if [[ "$PARAMETER_ANCHOR" =~ \#([^:]+) ]] then
			URL_ANCHOR="${BASH_REMATCH[1]}"
		else
			URL_ANCHOR=""
		fi

set | grep ^URL_
		return 0
	else
set | grep ^URL_
		URL_SCHEME=""
		URL_PATH_TO_FILE=""
		URL_DOMAIN=""
		URL_PORT=""
		URL_PARAMETER=""
		URL_ANCHOR=""
		return 1
	fi
}

function url_decode() {
	echo -e "${1//%/\\x}"
}


url_encode $(url_decode "http://www.test.com/path%20with%20spaces/test%2bplus.html")

function url_encode() {
	local i
	for (( i=0; i<${#1}; i++ )); do
		local c="${1:$i:1}"
		case $c in
		\ |!|\#|\$|\&|\'|\(|\)|\*|+|,|/|:|\;|=|\?|@|\[|\])
			printf "%%%02x" "'$c"
			;;
		*)
			echo -n $c
		esac
	done
}

#
# Credit to @jkishner for https://gist.github.com/jkishner/2fccb24640a27c2d7ac9
#
# Also interesting: https://gist.github.com/cdown/1163649
#
function url_encode2() {
    echo "$@" \
    | sed \
        -e 's/%/%25/g' \
        -e 's/ /%20/g' \
        -e 's/!/%21/g' \
        -e 's/"/%22/g' \
        -e "s/'/%27/g" \
        -e 's/#/%23/g' \
        -e 's/(/%28/g' \
        -e 's/)/%29/g' \
        -e 's/+/%2b/g' \
        -e 's/,/%2c/g' \
        -e 's/-/%2d/g' \
        -e 's/;/%3b/g' \
        -e 's/?/%3f/g' \
        -e 's/@/%40/g' \
        -e 's/\$/%24/g' \
        -e 's/\&/%26/g' \
        -e 's/\*/%2a/g' \
        -e 's/\./%2e/g' \
        -e 's/\[/%5b/g' \
        -e 's/\\/%5c/g' \
        -e 's/\]/%5d/g' \
        -e 's/\^/%5e/g' \
        -e 's/_/%5f/g' \
        -e 's/`/%60/g' \
        -e 's/{/%7b/g' \
        -e 's/|/%7c/g' \
        -e 's/}/%7d/g' \
        -e 's/~/%7e/g'
}

#        -e 's/:/%3a/g' \
#        -e 's/\//%2f/g' \


: << __X
#function url_is() {
#	echo "$*" | grep -q '^[^:]\{1,\}://[^/]\{1,\}[^?#]\{0,\}[^?]\{0,\}[^#]\{0,\}'
#}

# Positive tests
url_is "scheme://domain.name:port/path/to/file.ext?parameter#anchor" || echo FAIL 1
url_is "scheme://domain.name:port/path/to/file.ext?parameter" || echo FAIL 2
url_is "scheme://domain.name:port/path/to/file.ext" || echo FAIL 3
url_is "scheme://domain.name:port/path/to/file" || echo FAIL 4
url_is "scheme://domain.name:port/path/to/" || echo FAIL 5
url_is "scheme://domain.name:port/" || echo FAIL 6
url_is "scheme://domain.name:port" || echo FAIL 7
url_is "scheme://domain.name" || echo FAIL 8
url_is "scheme://domain.name/" || echo FAIL 9
url_is "scheme://domain/" || echo FAIL 10

# negative tests
url_is "" && echo FAIL 100
url_is "test.txt" && echo FAIL 101
url_is "scheme://" && echo FAIL 102
url_is "scheme://" && echo FAIL 103
url_is "//server/path" && echo FAIL 104
url_is "/dir/file" && echo FAIL 105
url_is "/dir/file.ext" && echo FAIL 106

#url_split "scheme://domain.name:9087/path/to/file.ext?parameter#anchor"

__X
