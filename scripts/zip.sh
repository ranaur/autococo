function unzip_at() {
#echo unzip_at "$@"
        # unzips file $1 to directory $2
        if [ ! -f "$1" ] ; then return -1; fi

        mkdir -p "$2" || return -2

        #unzip "$1" -d "$2" &> /dev/null
	unzipStrip "$1" "$2"

	return $?
}

# https://superuser.com/questions/518347/equivalent-to-tars-strip-components-1-in-unzip
# unzip featuring an enhanced version of tar's --strip-components=1
# Usage: unzip-strip ARCHIVE [DESTDIR] [EXTRA_cp_OPTIONS]
# Derive DESTDIR to current dir and archive filename or toplevel dir
unzipStrip() {
#echo uzipStrip "$@" 
    set -e
    local archive=$1
    local destdir=${2:-}
    shift; shift || :
    local tmpdir=$(mktemp -d)
    trap 'rm -rf -- "$tmpdir"' EXIT
    unzip -qd "$tmpdir" -- "$archive"
    shopt -s dotglob
    local files=("$tmpdir"/*) name i=1
    if (( ${#files[@]} == 1 )) && [[ -d "${files[0]}" ]]; then
        name=$(basename "${files[0]}")
        files=("$tmpdir"/*/*)
    else
        name=$(basename "$archive"); name=${archive%.*}
        files=("$tmpdir"/*)
    fi
    if [[ -z "$destdir" ]]; then
        destdir=./"$name"
    fi
    while [[ -f "$destdir" ]]; do destdir=${destdir}-$((i++)); done
    mkdir -p "$destdir"
    cp -ar "$@" -t "$destdir" -- "${files[@]}"

    rm -rf -- "$tmpdir"
}

function expandZip() {
	# expandZip zipfile directory
	# expands the zipfile in the directory striping the first directory

	rm -Rf $TEMP_DIR
	mkdir -p $TEMP_DIR
	pushd $TEMP_DIR > /dev/null
	extractZip "$1"
	popd > /dev/null


	rest_cmd=$(shopt -p dotglob)  # Get restoration command
	shopt -s dotglob              # Set option
	mv "$TEMP_DIR"/*/* "$2" &> /dev/null
	rmdir "$TEMP_DIR"/* &> /dev/null
	mv "$TEMP_DIR"/* "$2" &> /dev/null
	rmdir "$TEMP_DIR" &> /dev/null
	${rest_cmd}
}

