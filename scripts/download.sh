DOWNLOADER=`which curl`

function download() { # url file => download URL to file
	$DOWNLOADER "$1" --create-dirs -k -L -o "$2"

	return $?
}

# from: https://stackoverflow.com/questions/27212019/convert-percent-encoded-file-url-to-local-file-in-bash
function download_decodeURL() {
   printf "$(sed 's#^file://##;s/+/ /g;s/%\(..\)/\\x\1/g;' <<< "$@")\n";
}

