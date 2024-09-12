#!/bin/bash

URL_DOWNLOAD_CACHE="${URL_DOWNLOAD_CACHE:-$HOME/cache}"
if [ ! -d "$URL_DOWNLOAD_CACHE" ] ; then mkdir -p "$URL_DOWNLOAD_CACHE" ; fi

if [[ -z "$CMD_CURL" ]] ; then CMD_CURL=`which curl` ; fi


function url_is() {
#1&>2 echo "DEBUG: function $FUNCNAME[$#]("$@")" 
	[ $# -ne 1 ] && return -1
	# ^([^:]\{1,\})://(.\{1,\})([^?#]\{0,\})([^?]\{0,\})([^#]\{0,\})
	if [[ "$1" =~ ([^:]+)://([^/]+)(.*)$ ]] then
		URL_SCHEME="${BASH_REMATCH[1]}"
		local URL_DOMAIN_PORT="${BASH_REMATCH[2]}"
		local URL_FILE_PARAMETER_ANCHOR="${BASH_REMATCH[3]}"

		#echo "URL_SCHEME=$URL_SCHEME"
		#echo "URL_DOMAIN_PORT=$URL_DOMAIN_PORT"
		#echo "URL_FILE_PARAMETER_ANCHOR=$URL_FILE_PARAMETER_ANCHOR"

		if [[ "$URL_DOMAIN_PORT" =~ ([^:]+):(.+) ]] then
			URL_DOMAIN="${BASH_REMATCH[1]}"
			URL_PORT="${BASH_REMATCH[2]}"
		else
			URL_DOMAIN="${URL_DOMAIN_PORT}"
			URL_PORT=""
		fi
		#echo "URL_DOMAIN=$URL_DOMAIN"
		#echo "URL_PORT=$URL_PORT"
		
		if [[ "$URL_FILE_PARAMETER_ANCHOR" =~ \#([^#]+) ]] then
			URL_ANCHOR="${BASH_REMATCH[1]}"
			URL_FILE_PARAMETER_ANCHOR=${URL_FILE_PARAMETER_ANCHOR%#$URL_ANCHOR}
		else
			URL_ANCHOR=""
		fi
		#echo "URL_ANCHOR=$URL_ANCHOR"

		if [[ "$URL_FILE_PARAMETER_ANCHOR" =~ \?([^?]+) ]] then
			URL_PARAMETER="${BASH_REMATCH[1]}"
			URL_FILE_PARAMETER_ANCHOR=${URL_FILE_PARAMETER_ANCHOR%?$URL_PARAMETER}
		else
			URL_PARAMETER=""
		fi
		#echo "URL_PARAMETER=$URL_PARAMETER"

		URL_PATH_TO_FILE="${URL_FILE_PARAMETER_ANCHOR}"
		#echo "URL_PATH_TO_FILE=$URL_PATH_TO_FILE"

#set | grep ^URL_
		return 0
	else
#set | grep ^URL_
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
#1&>2 echo "DEBUG: function $FUNCNAME[$#]("$@")" 
	[ $# -ne 1 ] && return -1
	echo -e "${1//%/\\x}"
  	
	# Alternative
	## from: https://stackoverflow.com/questions/27212019/convert-percent-encoded-file-url-to-local-file-in-bash
	#printf "$(sed 's#^file://##;s/+/ /g;s/%\(..\)/\\x\1/g;' <<< "$@")\n";
}

function url_encode_string() {
#1&>2 echo "DEBUG: function $FUNCNAME[$#]("$@")" 
	[ $# -gt 2 ] && return -1
	local i
	local encoded=""
	for (( i=0; i<${#1}; i++ )); do
		local c="${1:$i:1}"
		case $c in
		\ |!|\#|\$|\&|\'|\(|\)|\*|+|,|:|\;|=|\?|@|\[|\])
			encoded="${encoded}$(printf "%%%02x" "'$c")"
			;;
		/)
			if [ -z "$2" ] ; then
				encoded="${encoded}$(printf "%%%02x" "'$c")"
			else
				encoded="${encoded}$c"
			fi
			;;
		*)
			encoded="${encoded}$c"
		esac
	done
	
	echo -n $encoded
}

function url_encode() {
#1&>2 echo "DEBUG: function $FUNCNAME[$#]("$@")" 
	[ $# -ne 1 ] && return -1
	
	url_is "$1"
	if [ $? = 1 ] ; then # not an URL
		echo "$1"
	else
		#set | grep ^URL_
		
		URL_PATH_TO_FILE="$(url_encode_string "$URL_PATH_TO_FILE" true)"
		
		[ ! -z "$URL_PORT" ] && URL_PORT=":${URL_PORT}"
		[ ! -z "$URL_PARAMETER" ] && URL_PARAMETER="?$(url_encode_string "$URL_PARAMETER")"
		[ ! -z "$URL_ANCHOR" ] && URL_ANCHOR="#$(url_encode_string "$URL_ANCHOR")"
		echo -n "${URL_SCHEME}://${URL_DOMAIN}${URL_PORT}${URL_PATH_TO_FILE}${URL_PARAMETER}${URL_ANCHOR}"
	fi
}




# Positive tests
#url_is "scheme://domain.name:port/path/to/file.ext?parameter#anchor" || echo FAIL 1
#url_is "scheme://domain.name:port/path/to/file.ext?parameter" || echo FAIL 2
#url_is "scheme://domain.name:port/path/to/file.ext" || echo FAIL 3
#url_is "scheme://domain.name:port/path/to/file" || echo FAIL 4
#url_is "scheme://domain.name:port/path/to/" || echo FAIL 5
#url_is "scheme://domain.name:port/" || echo FAIL 6
#url_is "scheme://domain.name:port" || echo FAIL 7
#url_is "scheme://domain.name" || echo FAIL 8
#url_is "scheme://domain.name/" || echo FAIL 9
#url_is "scheme://domain/" || echo FAIL 10
# negative tests
#url_is "" && echo FAIL 100
#url_is "test.txt" && echo FAIL 101
#url_is "scheme://" && echo FAIL 102
#url_is "scheme://" && echo FAIL 103
#url_is "//server/path" && echo FAIL 104
#url_is "/dir/file" && echo FAIL 105
#url_is "/dir/file.ext" && echo FAIL 106

#url_encode "$(url_decode "http://www.test.com/path%20with%20spaces/test%2bplus.html")"

#set | grep ^URL_

function url_fetch() { # echoes the filename
	[ $# -ne 1 ] && return -1

	url_is "$1"
	if [ ! $? ] ; then
		return 0
	fi
	
	local cache_filename="$URL_DOWNLOAD_CACHE/${URL_DOMAIN}${URL_PORT}${URL_PATH_TO_FILE}"

	mkdir -p "$(dirname "$cache_filename")"
	if [ ! -f "$cache_filename" ] ; then
		url_download "$1" "$cache_filename"
		local res=$?
		if [ $res != 0 ] ; then
			return $res
		fi
	fi

	echo "$cache_filename"

	return $?
}

function url_download() { # url file => download URL to file
	[ $# -ne 1 ] && [ $# -ne 2 ] && return -1
	
	"$CMD_CURL" "$1" --create-dirs -k -L > "$2"

	return $?
}

