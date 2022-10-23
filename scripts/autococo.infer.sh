function has_substring() {
        [[ "$1" == *"$2"* ]]
}

function infer_cocoarchive() {
	DIRNAME=$(dirname "$1")
	GENRE=$(basename "$DIRNAME")

	FILE=$(realpath "$1")
	FILENAME=`basename "$1"`
	MD5=$(md5sum "$FILE" | cut -b -32)

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
	else
		SSC=no
	fi

	if has_substring "$PROGRAM" "(Real Talker required)" ; then
		RTR=yes
		PROGRAM="${PROGRAM// (Real Talker required)/}"
	else
		RTR=no
	fi

	VIDEO_FORMAT=NTSC
	if has_substring "$PROGRAM" "(PAL)" ; then
		VIDEO_FORMAT=PAL
		PROGRAM="${PROGRAM// (PAL)/}"
	fi
	if has_substring "$PROGRAM" "(PAL 50Hz Coco 2)" ; then
		VIDEO_FORMAT=PAL50Hz
		PROGRAM="${PROGRAM// (PAL 50Hz Coco 2)/}"
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

	fi
	if has_substring "$PROGRAM" "(6309 compatible)" ; then
		PROCESSOR=6309
		PROGRAM="${PROGRAM// (6309 compatible)/}"
	fi
	if has_substring "$PROGRAM" "(6809 optimized)" ; then
		PROCESSOR=6809
		PROGRAM="${PROGRAM// (6809 optimized)/}"
	fi

	if has_substring "$PROGRAM" "(CocoVGA)" ; then
		PROGRAM="${PROGRAM// (CocoVGA)/}"
		COCOVGA=yes
	else
		COCOVGA=no
	fi

	if has_substring "$PROGRAM" "(SG-8)" ; then
		PROGRAM="${PROGRAM// (SG-8)/}"
		SG=SG-8
	fi
	if has_substring "$PROGRAM" "(SG-8 intro)" ; then
		PROGRAM="${PROGRAM// (SG-8 intro)/}"
		SG=SG-8\ Intro
	fi
	if has_substring "$PROGRAM" "(SG-12)" ; then
		PROGRAM="${PROGRAM// (SG-12)/}"
		SG=SG-12
	fi
	if has_substring "$PROGRAM" "(SG-12 intro)" ; then
		PROGRAM="${PROGRAM// (SG-12 intro)/}"
		SG=SG-12\ Intro
	fi
	if has_substring "$PROGRAM" "(SG-24)" ; then
		PROGRAM="${PROGRAM// (SG-24)/}"
		SG=SG-24\ Intro
	fi
	if has_substring "$PROGRAM" "(SG-24 intro)" ; then
		PROGRAM="${PROGRAM// (SG-24 intro)/}"
	fi

	if has_substring "$PROGRAM" "(CoCo PSG)" ; then
		COCOPSG=yes
		PROGRAM="${PROGRAM// (CoCo PSG)/}"
	else
		COCOPSG=yes
	fi
	if has_substring "$PROGRAM" "(Enhanced by sixxie)" ; then
		SIXXIE=yes
		PROGRAM="${PROGRAM// (Enhanced by sixxie)/}"
	else
		SIXXIE=no
	fi

	if has_substring "$PROGRAM" "(alt)" ; then
		PROGRAM="${PROGRAM// (alt)/}"
		ALT=yes
	else
		ALT=false
	fi

	PORT=no
	if has_substring "$PROGRAM" "(Coco port)" ; then
		PORT=COCO
		PROGRAM="${PROGRAM// (Coco port)/}"
	fi
	if has_substring "$PROGRAM" "(Ports from ZX Spectrum)" ; then
		PORT=ZXSPECTRUM
		PROGRAM="${PROGRAM// (Ports from ZX Spectrum)/}"
	fi

	if has_substring "$PROGRAM" "(Cheat)" ; then
		PROGRAM="${PROGRAM// (Cheat)/}"
		CHEAT=yes
	else
		CHEAT=no
	fi

	if has_substring "$PROGRAM" "(Text)" ; then
		PROGRAM="${PROGRAM// (Text)/}"
		TEXT=yes
	else
		TEXT=no
	fi

	LANGUAGE=English
	if has_substring "$PROGRAM" "(English translation)" ; then
		TRANSLATION=yes
		PROGRAM="${PROGRAM// (English translation)/}"
	fi
	if has_substring "$PROGRAM" "(Portuguese)" ; then
		LANGUAGE=Portuguese
		PROGRAM="${PROGRAM// (Portuguese)/}"
	fi
	if has_substring "$PROGRAM" "(Portuguese Translation)" ; then
		LANGUAGE=Portuguese
		TRANSLATION=yes
		PROGRAM="${PROGRAM// (Portuguese Translation)/}"
	fi
	if has_substring "$PROGRAM" "(French)" ; then
		LANGUAGE=French
		PROGRAM="${PROGRAM// (French)/}"
	fi
	if has_substring "$PROGRAM" "(French Translation)" ; then
		LANGUAGE=French
		TRANSLATION=yes
		PROGRAM="${PROGRAM// (French Translation)/}"
	fi

AUTHOR="${PROGRAM#* (}"
AUTHOR="${AUTHOR%%)*}"
if [ -z "$AUTHOR" ] ; then
	AUTHOR="Unknown"
fi
PROGRAM="${PROGRAM% (*}"

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

# extract zip file
#mkdir -p "$TMP"
#unzip -d "$TMP" "$FILE" > /dev/null
#mv "$TMP/${FILENAME%.*}"/* "${PROGRAM_DIR}/"
#rm -R "$TMP"
#
#
#pushd "$PROGRAM_DIR" > /dev/null
#METAFILE="METAFILE.YML"

#echo PROGRAM $PROGRAM
cat << __EOF__
package:
  program: $PROGRAM
  author: $AUTHOR
  genre: $GENRE
  file: $FILENAME
  url: $URL
  md5: $MD5
  language: $LANGUAGE

setup:
  architecture: $MACHINE
  cpu: $PROCESSOR
  tv-type: ${VIDEO_FORMAT,,}
  artifact: no
  os9: $OS9
  ssc: $SSC
  real talk: $RTR
__EOF__

}

function guess_dsk() { # file.dsk
#echo guess_dsk "$@"
	# return 0 of could guess, -1 if not
	# outputs: $command => command to load the disk
	dsk_dir "$1" -BB
	nfiles=${#dir[@]}
	if [ $nfiles == 0 ] ; then
		# no files or error on decb, probably a OS-9 disk
		command="DOS"
		return 0
	fi

	if [ $nfiles == 1 ] ; then
		# easy, only one file in the dir
		line=${dir[0]}
		file=$(echo "$line" | cut -d : -f 1)
		ext=$(echo "$line" | cut -d : -f 2)
#echo EXT $ext
		case $ext in
		BAS)
			command="RUN\"$file\""
			return 0
			;;
		BIN)
			command="LOADM\"$file\":EXEC"
			return 0
			;;
		*)
			command=""
			echo cannot infer: only one file that is not BAS nor BIN
			return -1
			;;
		esac
	fi

	echo PENDING: more than one file that is not BAS nor BIN
	return -1

	#>&2 echo "createCommand" "$@"
	#decb dir "$1"
#	FIRST_BAS="`decb dir "$1" | tail +3 | grep ".........BAS" | tail -1 | cut -b 1-8`"
#	FIRST_BAS=`trim "${FIRST_BAS}"`
#	if [ -z "$FIRST_BAS" ] ; then
#		FIRST_BIN="`decb dir "$1" | tail +3 | grep ".........BIN" | tail -1 | cut -b 1-8`"
#		FIRST_BIN=`trim "${FIRST_BIN}"`
#		if [ ! -z "$FIRST_BIN" ] ; then
#			cat << __EOF__
#command: LOADM"$FIRST_BIN":EXEC
#__EOF__
#		fi
#	else
#		cat << __EOF__
#command: RUN"$FIRST_BAS"
#__EOF__
#	fi
	TODO # infer the command, inspecting the disk content
	# if there is a RUN.BAS / AUTOEXEC , run it.
	# If there is X.BIN & X.BAS run the BAS
}

function infer_zip() { # file.zip outfile.autococo
#echo infer_zip "$@"
	WORKDIR="$WORKDIR/infer"
#echo WORKDIR "$WORKDIR"
	unzip_at "$1" "$WORKDIR"

	pushd "$WORKDIR" > /dev/null
#ls -la

	# get all the DSKs files and sort the *BOOT.DSK first, then alphabetically.
	shopt -s nocaseglob
	original_dsks=(*.DSK)
	dsks=()
	i=0
	for element in "${original_dsks[@]}"
	do

#echo ELEMENT $element
		if [[ "$element" =~ "BOOT.DSK" ]] ; then
#echo MATCH
			unset original_dsks[$i]
			dsks+=("$element")
		fi
		i=$((i+1))
	done
	IFS=$'\n' original_dsks=($(sort <<<"${original_dsks[*]}"))
	unset IFS
	dsks+=(${original_dsks[@]})

	i=0
	for disk in ${dsks[@]} ; do
#echo DISK $disk
		diskfile=$(basename "$disk")
		if [ $OS9 == yes ] ; then
			command=DOS
		else
			guess_dsk "$disk"
#echo guess result $?
		fi
		if [ $i == 0 ] ; then # first disk only
			echo "  command: $command"
		fi
		echo "  floppy$i: $diskfile"
		i=$(($i+1))
	done
	popd > /dev/null

	#rm -rf "$WORKDIR"
	return 0
}

function infer_dsk() { # file.dsk outfile.autococo [number = 0]
	number=${3:-0}
	substitute_yaml "$2" floppy$number "$1"

	TODO # 
}

function infer_cas() { # file.dsk outfile.autococo
	substitute_yaml "$2" cassette "$1"

	TODO # look the type of the cassette (BAS/BIN) and issue the command CLOAD/CLOADM
}

function infer_ccc() { # file.dsk outfile.autococo
	substitute_yaml "$2" rompack "$1"
	TODO # test
}
