#!/bin/bash

source `dirname "$0"`/config.sh

if [[ -z "$1" ]] ; then
	cat << __EOF__
usage: `basename $0` <Archive Dir>

	Expand each diretory from <Archive Dir>, that means:
		* each .ZIP file is expanded on it's name
		* other files are copied
		* subdirectories are created with "@" apended
__EOF__
	exit 0
fi

shopts -s nocaseglob
shopts -s nullglob
function process_dir() {
	pushd "$1" > /dev/null
	for file in * ; do
		P_FILE=`realpath --relative-to="$2" "$1/$file"`
		if [[ -d "$file" ]] ; then
			mkdir -p "$PROGRAM_DIR/\@$file"
			process_dir "$ARCHIVE/$file" "$PROGRAM_DIR/\@$file"
		else

			pushd "$2" > /dev/null
			echo `pwd`: cp "$P_FILE" .
			popd > /dev/null
		fi
	done
	popd > /dev/null
}

function extractZip() {
	unzip "$1"
	#7z x "$1"
}

mkdir -p "$PROGRAM_DIR/$1"
process_dir "$ARCHIVE_DIR/colorcomputerarchive.com/repo/$1" "$PROGRAM_DIR/$1"

exit $RES
