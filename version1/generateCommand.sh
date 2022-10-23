#!/bin/bash

source `dirname "$0"`/config.sh

if [[ -z "$1" ]] ; then
	cat << __EOF__
usage: `basename $0` <dir>

	Append a command: line guessing the command based on the first disk
__EOF__
	exit 0
fi

DSKDIR="$1"
METAFILE="$DSKDIR/METAFILE.YML"

function guessCommand() {
#>&2 echo $0 "$@"
        FIRST_BAS="`decb dir "$1" | tail +3 | grep ".........BAS" | tail -1 | cut -b 1-8`"
#>&2 echo RES=$?
        FIRST_BAS=`trim "${FIRST_BAS}"`
        if [ -z "$FIRST_BAS" ] ; then
                FIRST_BIN="`decb dir "$1" | tail +3 | grep ".........BIN" | tail -1 | cut -b 1-8`"
#>&2 echo RES=$?
                FIRST_BIN=`trim "${FIRST_BIN}"`
                if [ ! -z "$FIRST_BIN" ] ; then
			echo LOADM\"$FIRST_BIN\":EXEC
		else
			echo "DOS"
                fi
        else
		echo RUN\"$FIRST_BAS\"
        fi
}

floppy0=`get_yaml "$METAFILE" floppy0`
os=`get_yaml "$METAFILE" OS`
command=`get_yaml "$METAFILE" command`

echo "*** $DSKDIR" 
#if [[ ! -z "$floppy0" && -z "$command" ]] ; then
if [[ ! -z "$floppy0" ]] ; then
	if [[ $os == "RS-DOS" ]] ; then
		COMMAND=`guessCommand "$DSKDIR/$floppy0"`
	else
		COMMAND=DOS
	fi
#echo command: $COMMAND
	substitute_yaml "$METAFILE" command "$COMMAND"
fi

exit 0
