function autococo_url_archive_dir() { # url => echoes the directory that holds the cache (archive) for the URL
	if [[ $# -ne 1 ]] ; then return -1 ; fi
	local ret="$1"

	# removes protocol
	ret=${ret#*://}
	
	echo $(download_decodeURL "$ret")
	return 0
}
	
function autococo_download() { # [-f] url => downloads URL to archive directory ($ARCHIVE_DIR) if it does' t exist (-f forces) - echoes the local file name
	local force=false
	if [[ "$1" == "-f" ]] ; then
		force=true
		shift
	fi
	if [[ $# -ne 1 ]] ; then return -1; fi

	local destination=$(realpath "$ARCHIVE_DIR")/$(autococo_url_archive_dir "$1")

	if [[ -f "$destination" ]] && [[ "$force" == false ]] ; then
		echo "$destination"
#echo DOWNLOAD: Use cache >&2
		return 0
	fi

	download "$1" "$destination.downloading"
	if [[ $? == 0 ]] ; then
		mv -f  "$destination.downloading" "$destination"
		echo "$destination"
#echo DOWNLOAD: Download ok >&2
		return 0
	else
		rm "$destination.downloading"
#echo DOWNLOAD: Download failed >&2
		return -1
	fi
}
