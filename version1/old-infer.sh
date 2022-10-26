#!/bin/bash
shopt -s nullglob
#DECB="../Tools/toolshed-2.2/decb.exe"
DECB="../Tools/decb"
DECB=`realpath  "$DECB"`

function has_substring() {
	[[ "$1" == *"$2"* ]]
}

function decb() {
	# floptool.exe flopdir input_format filesystem
	COMMAND="$1"
	FILE=`basename "$2"`
	DIR=`dirname "$2"`
	shift 2
	pushd "$DIR" > /dev/null
	"$DECB" "$COMMAND" "$FILE" "$@"
	popd >  /dev/null
}

trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    printf '%s' "$var"
}

function createCommand() {
#>&2 echo "createCommand" "$@"
#decb dir "$1"
	FIRST_BAS="`decb dir "$1" | tail +3 | grep ".........BAS" | tail -1 | cut -b 1-8`"
	FIRST_BAS=`trim "${FIRST_BAS}"`
	if [ -z "$FIRST_BAS" ] ; then
		FIRST_BIN="`decb dir "$1" | tail +3 | grep ".........BIN" | tail -1 | cut -b 1-8`"
		FIRST_BIN=`trim "${FIRST_BIN}"`
		if [ ! -z "$FIRST_BIN" ] ; then
			cat << __EOF__
command: LOADM"$FIRST_BIN":EXEC
__EOF__
		fi
	else
		cat << __EOF__
command: RUN"$FIRST_BAS"
__EOF__
	fi
}

function createAutoexec() {
	DIR=`dirname "$1"`
	pushd "$DIR"
	DSK=`basename "$1"`

	if [ -f "$DSK.ORIG" ] ; then
		echo "--- Has original disk"
		cp "$DSK.ORIG" "$DSK"
	else
		echo "--- Make backup of the original disk"
		cp "$DSK" "$DSK.ORIG"
	fi

	if [ -f AUTOEXEC.BAS ] ; then
		echo "--- There is an autoexec in the directory"
		decb copy AUTOEXEC.BAT "$DSK,AUTOEXEC.BAS" -t -0 -b -r 
		exit $?
	fi

	AUTOEXEC_BAS=`decb dir "$DSK" | tail +3 | grep "AUTOEXEC.BAS" | tail -1`
	if [ ! -z "$AUTOEXEC_BAS" ] ; then
		echo "--- There is an AUTOEXEC.BAS in the disk"
		exit 0
	fi

	echo "--- Create an AUTOEXEC for the first Binary"
	FIRST_BIN=`decb dir "$t" | tail +3 | grep ".........BIN" | tail -1 | cut -d\  -f 1`
	cat > AUTOEXEC.BAT << __EOF__
10 LOADM"$FIRST_BIN"
20 EXEC
__EOF__
	decb copy AUTOEXEC.BAT "$DSK,AUTOEXEC.BAS" -t -0 -b -r
	rm AUTOEXEC.BAT
	popd "$1"
}

ARCHIVEDIR=`readlink -f $0`
ARCHIVEDIR=`dirname "$ARCHIVEDIR"`
EXTRAS=""

FILE="$1"
FILENAME=`basename "$1"`

	# remove extension (.zip)
PROGRAM="${FILENAME%.*}"
MACHINE=coco2
if has_substring "$PROGRAM" "(Coco 3)" ; then
	MACHINE=coco3
	PROGRAM="${PROGRAM// (Coco 3)/}"
fi
if has_substring "$PROGRAM" "(Coco 1-2)" ; then
	MACHINE=coco1
	PROGRAM="${PROGRAM// (Coco 1-2)/}"
fi

if has_substring "$PROGRAM" "(SSC)" ; then
	SSC=yes
	PROGRAM="${PROGRAM// (SSC)/}"
	EXTRAS="$EXTRAS (SSC)"
else
	SSC=no
fi

if has_substring "$PROGRAM" "(Real Talker required)" ; then
	RTR=yes
	PROGRAM="${PROGRAM// (Real Talker required)/}"
	EXTRAS="$EXTRAS (RT)"
else
	RTR=no
fi

VIDEO_FORMAT=NTSC
if has_substring "$PROGRAM" "(PAL)" ; then
	VIDEO_FORMAT=PAL
	PROGRAM="${PROGRAM// (PAL)/}"
	EXTRAS="$EXTRAS (PAL)"
fi
if has_substring "$PROGRAM" "(PAL 50Hz Coco 2)" ; then
	VIDEO_FORMAT=PAL50Hz
	PROGRAM="${PROGRAM// (PAL 50Hz Coco 2)/}"
	EXTRAS="$EXTRAS (PAL 50Hz)"
fi
PROGRAM="${PROGRAM// (NTSC)/}"

if has_substring "$PROGRAM" "(OS-9)" ; then
	OS9=yes
	PROGRAM="${PROGRAM// (OS-9)/}"
else
	OS9=no
fi

PROCESSOR=6809
if has_substring "$PROGRAM" "(6309 optimized)" ; then
	PROCESSOR=6309
	PROGRAM="${PROGRAM// (6309 optimized)/}"
	EXTRAS="$EXTRAS (6309)"

fi
if has_substring "$PROGRAM" "(6309 compatible)" ; then
	PROCESSOR=6309
	PROGRAM="${PROGRAM// (6309 compatible)/}"
	EXTRAS="$EXTRAS (6309)"
fi
if has_substring "$PROGRAM" "(6809 optimized)" ; then
	PROCESSOR=6309
	PROGRAM="${PROGRAM// (6809 optimized)/}"
	EXTRAS="$EXTRAS (6809)"
fi

if has_substring "$PROGRAM" "(CocoVGA)" ; then
	EXTRAS="$EXTRAS (CocoVGA)"
	PROGRAM="${PROGRAM// (CocoVGA)/}"
fi
if has_substring "$PROGRAM" "(SG-8)" ; then
	EXTRAS="$EXTRAS (SG-8)"
	PROGRAM="${PROGRAM// (SG-8)/}"
fi
if has_substring "$PROGRAM" "(SG-8 intro)" ; then
	EXTRAS="$EXTRAS (SG-8 intro)"
	PROGRAM="${PROGRAM// (SG-8 intro)/}"
fi
if has_substring "$PROGRAM" "(SG-12)" ; then
	EXTRAS="$EXTRAS (SG-12)"
	PROGRAM="${PROGRAM// (SG-12)/}"
fi
if has_substring "$PROGRAM" "(SG-12 intro)" ; then
	EXTRAS="$EXTRAS (SG-12 intro)"
	PROGRAM="${PROGRAM// (SG-12 intro)/}"
fi
if has_substring "$PROGRAM" "(SG-24)" ; then
	EXTRAS="$EXTRAS (SG-24)"
	PROGRAM="${PROGRAM// (SG-24)/}"
fi
if has_substring "$PROGRAM" "(SG-24 intro)" ; then
	EXTRAS="$EXTRAS (SG-24 intro)"
	PROGRAM="${PROGRAM// (SG-24 intro)/}"
fi
if has_substring "$PROGRAM" "(CoCo PSG)" ; then
	EXTRAS="$EXTRAS (CoCo PSG)"
	PROGRAM="${PROGRAM// (CoCo PSG)/}"
fi
if has_substring "$PROGRAM" "(Enhanced by sixxie)" ; then
	EXTRAS="$EXTRAS (Enhanced by sixxie)"
	PROGRAM="${PROGRAM// (Enhanced by sixxie)/}"
fi
if has_substring "$PROGRAM" "(alt)" ; then
	EXTRAS="$EXTRAS (alt)"
	PROGRAM="${PROGRAM// (alt)/}"
fi
if has_substring "$PROGRAM" "(Coco port)" ; then
	EXTRAS="$EXTRAS (Coco port)"
	PROGRAM="${PROGRAM// (Coco port)/}"
fi
if has_substring "$PROGRAM" "(English translation)" ; then
	EXTRAS="$EXTRAS (English translation)"
	PROGRAM="${PROGRAM// (English translation)/}"
fi
if has_substring "$PROGRAM" "(Cheat)" ; then
	EXTRAS="$EXTRAS (Cheat)"
	PROGRAM="${PROGRAM// (Cheat)/}"
fi
if has_substring "$PROGRAM" "(Text)" ; then
	EXTRAS="$EXTRAS (Text)"
	PROGRAM="${PROGRAM// (Text)/}"
fi
if has_substring "$PROGRAM" "(Ports from ZX Spectrum)" ; then
	EXTRAS="$EXTRAS (Ports from ZX Spectrum)"
	PROGRAM="${PROGRAM// (Ports from ZX Spectrum)/}"
fi
if has_substring "$PROGRAM" "(Portuguese)" ; then
	EXTRAS="$EXTRAS (Portuguese)"
	PROGRAM="${PROGRAM// (Portuguese)/}"
fi
if has_substring "$PROGRAM" "(Portuguese Translation)" ; then
	EXTRAS="$EXTRAS (Portuguese Translation)"
	PROGRAM="${PROGRAM// (Portuguese Translation)/}"
fi
if has_substring "$PROGRAM" "(French)" ; then
	EXTRAS="$EXTRAS (French)"
	PROGRAM="${PROGRAM// (French)/}"
fi
if has_substring "$PROGRAM" "(French Translation)" ; then
	EXTRAS="$EXTRAS (French Translation)"
	PROGRAM="${PROGRAM// (French Translation)/}"
fi

AUTHOR="${PROGRAM#* (}"
AUTHOR="${AUTHOR%%)*}"
if [ -z "$AUTHOR" ] ; then
	AUTHOR="Unknown"
fi
PROGRAM="${PROGRAM% (*}$EXTRAS"

DIR=`dirname "$1"`
if [ -z "$2" ] ; then
	CATEGORY=`basename "$DIR"`
else
	SUBCATEGORY=`basename "$DIR"`
	CATEGORY=`dirname "$DIR"`
	CATEGORY=`basename "$CATEGORY"`
fi

TMP=/tmp/ez
URL="${FILE#*../Color Computer Archive/}"
URL="https://colorcomputerarchive.com/repo/${URL}"

PROGRAM_DIR="$ARCHIVEDIR/$CATEGORY/$SUBCATEGORY/$AUTHOR/$PROGRAM"
echo PROGRAM_DIR $PROGRAM_DIR
if [[ -d "$PROGRAM_DIR" ]] ; then
	echo Directory already exist! Cannot process $FILE
	exit 0
fi
mkdir -p "${PROGRAM_DIR}/"

# extract zip file
mkdir -p "$TMP"
unzip -d "$TMP" "$FILE" > /dev/null
mv "$TMP/${FILENAME%.*}"/* "${PROGRAM_DIR}/"
rm -R "$TMP"


pushd "$PROGRAM_DIR" > /dev/null
METAFILE="METAFILE.YML"

cat > "$METAFILE" << __EOF__
program: $PROGRAM
author: $AUTHOR
category: $CATEGORY
url: $URL
machine: $MACHINE
processor: $PROCESSOR
ssc: $SSC
real talk: $RTR
cartridge: disk
__EOF__

i=0
shopt -s nocaseglob
for t in *.DSK ; do
	echo floppy$i: `basename "$t"` >> "$METAFILE"
	if [ $i == 0 ] ; then
		if [ $OS9 == yes ] ; then
			echo "command: DOS" >> "$METAFILE"
		else
			createCommand "$t" >> "$METAFILE"
		fi
	fi
	i=$(($i+1))
done
popd > /dev/null

#./execute.sh "$CATEGORY/$AUTHOR/$PROGRAM"
