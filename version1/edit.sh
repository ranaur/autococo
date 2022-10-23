#!/bin/bash
ROMDIR=/media/share1/roms

source `dirname "$0"`/config.sh

if [[ -z "$1" ]] ; then
	cat << __EOF__
usage: `basename $0` <dir>

	Edit METAFILE on the given directory
__EOF__
	exit 0
fi

DIR="$1"

if [[ ! -f "$DIR/METAFILE.YML" ]] ; then
	DIR="$1/Disks"
fi

METAFILE="$DIR/METAFILE.YML"

if [[ ! -f "$METAFILE" ]] ; then
	echo METAFILE.YML was not found in $DIR
	exit -1
fi

shift

vi "$METAFILE"
exit $?

