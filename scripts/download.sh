#!/usr/bin/env bash
if [[ -z "$CMD_CURL" ]] ; then CMD_CURL=`which curl` ; fi

function download() { # url file => download URL to file
	>&2 echo "$CMD_CURL" "$1" --create-dirs -k -L -o "$2" 
	"$CMD_CURL" "$1" --create-dirs -k -L -o "$2"

	return $?
}

# from: https://stackoverflow.com/questions/27212019/convert-percent-encoded-file-url-to-local-file-in-bash
function download_decodeURL() {
   printf "$(sed 's#^file://##;s/+/ /g;s/%\(..\)/\\x\1/g;' <<< "$@")\n";
}

