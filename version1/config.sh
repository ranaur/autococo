BASE_DIR=`dirname "$0"`
ARCHIVE_DIR="$BASE_DIR"/archive
PROGRAM_DIR="$BASE_DIR"/programs
TEMP_DIR=/tmp/expandCoCo

function extractZip() {
	unzip "$1" > /dev/null
	#7z x "$1"
}

trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

# https://superuser.com/questions/518347/equivalent-to-tars-strip-components-1-in-unzip
# unzip featuring an enhanced version of tar's --strip-components=1
# Usage: unzip-strip ARCHIVE [DESTDIR] [EXTRA_cp_OPTIONS]
# Derive DESTDIR to current dir and archive filename or toplevel dir
unzipStrip() {
    set -eu
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
}

function decb() {
	DECB=`which decb`
	CMD="$1"
	DIRNAME=`dirname "$2"`
	DSKNAME=`basename "$2"`

	shift 2
	pushd "$DIRNAME" > /dev/null
	$DECB "$CMD" "$DSKNAME," "$@"
	RES=$?
	popd > /dev/null
	exit $RES
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

function parse_yaml {
   local prefix="$2"
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -ne 's|"|\\"|g' \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" \
	"$1" |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length("$3") > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

function get_yaml() {
	# get_yaml FILE tag
	grep "^[\s]*$2:" "$1" | sed -e "s/^$2:[[:blank:]]*\(.*\)$/\1/"
}

function substitute_yaml() {
>&2 echo substitute_yaml "$@"
	# substitute_yaml FILE tag value
	if grep -q "$2" "$1" ; then
#>&2 echo FOUND
		sed -i "s/\($2: \).*\$/\1$3/" "$1"
	else # not found, append in the end
#>&2 echo NOT FOUND
		echo "$2": "$3" >> "$1"
	fi
}

