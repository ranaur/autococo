# inferred__
# inferred_package_
#   inferred_package_author:
#   inferred_package_file:
#	inferred_package_genre:
#   inferred_package_language:
#   inferred_package_md5:
#   inferred_package_year:
#   inferred_package_reference:
#   inferred_package_program:
#   inferred_package_url:
# inferred_setup_
#   inferred_setup_architecture:
#   inferred_setup_artifact
#   inferred_setup_command
#   inferred_setup_cpu:
#   inferred_setup_floppy0
#   inferred_setup_os9:
#   inferred_setup_ssc:
#   inferred_setup_rtr:
#   inferred_setup_tv_type:
#   inferred_setup_cocovga:
#   inferred_setup_cocopsg:
# CCC
#   inferred_setup_rompack: <file>


function has_substring() {
        [[ "$1" == *"$2"* ]]
}

# infer package details from a cocoarchive file
#   Currently only works with ZIP file from Disks directory
#
function infer_archive_cocoarchive() {
#echo FILE: "$1" >&2
	FULLFILEPATH=$(realpath "$1")

	DIRNAME=$(dirname "$FULLFILEPATH")
	inferred_package_genre=$(basename "$DIRNAME")

	inferred_package_file=`basename "$1"`
	inferred_package_md5=$(md5sum "$FULLFILEPATH" | cut -b -32)

		# remove extension (.zip)
	PROGRAM="${inferred_package_file%.*}"
	inferred_setup_architecture=coco2
	if has_substring "$PROGRAM" "(Coco 3)" ; then
		inferred_setup_architecture=coco3
		PROGRAM="${PROGRAM// (Coco 3)/}"
	fi
	if has_substring "$PROGRAM" "(Coco 1-2)" ; then
		inferred_setup_architecture=coco1
		PROGRAM="${PROGRAM// (Coco 1-2)/}"
	fi

	if has_substring "$PROGRAM" "(SSC)" ; then
		inferred_setup_ssc=yes
		PROGRAM="${PROGRAM// (SSC)/}"
	else
		inferred_setup_ssc=no
	fi

	if has_substring "$PROGRAM" "(Real Talker required)" ; then
		inferred_setup_rtr=yes
		PROGRAM="${PROGRAM// (Real Talker required)/}"
	else
		inferred_setup_rtr=no
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
	inferred_setup_tv_type=${VIDEO_FORMAT,,}

	if has_substring "$PROGRAM" "(OS-9)" ; then
		inferred_setup_os9=yes
		PROGRAM="${PROGRAM// (OS-9)/}"
	else
		inferred_setup_os9=no
	fi

	inferred_setup_cpu=6809
	if has_substring "$PROGRAM" "(6309 optimized)" ; then
		inferred_setup_cpu=6309
		PROGRAM="${PROGRAM// (6309 optimized)/}"

	fi
	if has_substring "$PROGRAM" "(6309 compatible)" ; then
		inferred_setup_cpu=6309
		PROGRAM="${PROGRAM// (6309 compatible)/}"
	fi
	if has_substring "$PROGRAM" "(6809 optimized)" ; then
		inferred_setup_cpu=6809
		PROGRAM="${PROGRAM// (6809 optimized)/}"
	fi

	if has_substring "$PROGRAM" "(CocoVGA)" ; then
		PROGRAM="${PROGRAM// (CocoVGA)/}"
		inferred_setup_cocovga=yes
	else
		inferred_setup_cocovga=no
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
		inferred_setup_cocopsg=yes
		PROGRAM="${PROGRAM// (CoCo PSG)/}"
	else
		inferred_setup_cocopsg=no
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

	inferred_package_language=English
	if has_substring "$PROGRAM" "(English translation)" ; then
		TRANSLATION=yes
		PROGRAM="${PROGRAM// (English translation)/}"
	fi
	if has_substring "$PROGRAM" "(Portuguese)" ; then
		inferred_package_language=Portuguese
		PROGRAM="${PROGRAM// (Portuguese)/}"
	fi
	if has_substring "$PROGRAM" "(Portuguese Translation)" ; then
		inferred_package_language=Portuguese
		TRANSLATION=yes
		PROGRAM="${PROGRAM// (Portuguese Translation)/}"
	fi
	if has_substring "$PROGRAM" "(French)" ; then
		inferred_package_language=French
		PROGRAM="${PROGRAM// (French)/}"
	fi
	if has_substring "$PROGRAM" "(French Translation)" ; then
		inferred_package_language=French
		TRANSLATION=yes
		PROGRAM="${PROGRAM// (French Translation)/}"
	fi

	inferred_package_author="${PROGRAM#* (}"
	inferred_package_author="${inferred_package_author%%)*}"
	if [ -z "$inferred_package_author" ] ; then
		inferred_package_author="Unknown"
	fi
	# It is not the author, it's the year!
	if [[ "$inferred_package_author" =~ [0-9][0-9][0-9][0-9] ]] ; then
		inferred_package_year=$inferred_package_author
		PROGRAM="${PROGRAM// ($inferred_package_year)/}"
#echo "   YEAR: $inferred_package_year" >&2

		# It is not the author, it's the reference!
		inferred_package_author="${PROGRAM#* (}"
		inferred_package_author="${inferred_package_author%%)*}"
		if [[ "$inferred_package_author" =~ [0-9][0-9]-[0-9][0-9][0-9][0-9] ]] ; then
			inferred_package_reference=$inferred_package_author
			PROGRAM="${PROGRAM// ($inferred_package_reference)/}"

#echo "   REFERENCE: $inferred_package_reference" >&2
			inferred_package_author="${PROGRAM#* (}"
			inferred_package_author="${inferred_package_author%%)*}"
		fi
	fi
#echo "   AUTHOR: $inferred_package_author" >&2
	inferred_package_program="${PROGRAM% (*}"

	GROUPDIRNAME=$(dirname "$DIRNAME")
#echo GROUP: $(basename "$GROUPDIRNAME")
	MACROGROUPDIRNAME=$(dirname "$GROUPDIRNAME")
#echo MACROGROUP: $(basename "$MACROGROUPDIRNAME")
	if [ -z "$2" ] ; then
		CATEGORY=`basename "$DIR"`
#echo CATEGORY: $CATEGORY
	else
		SUBCATEGORY=`basename "$DIR"`
		CATEGORY=`dirname "$DIR"`
		CATEGORY=`basename "$CATEGORY"`
#echo CATEGORY: $CATEGORY
#echo SUBCATEGORY: $SUBCATEGORY
	fi

	TMP=/tmp/ez
	inferred_package_url="${FILE#*../Color Computer Archive/}"
	inferred_package_url="https://colorcomputerarchive.com/repo/${inferred_package_url}"

	inferred_package_+=(inferred_package_genre)
	inferred_package_+=(inferred_package_author)
	inferred_package_+=(inferred_package_file)
	inferred_package_+=(inferred_package_language)
	inferred_package_+=(inferred_package_md5)
	[[ ! -z "$inferred_package_year" ]] && inferred_package_+=(inferred_package_year)
	[[ ! -z "$inferred_package_reference" ]] && inferred_package_+=(inferred_package_reference)
	inferred_package_+=(inferred_package_program)
	inferred_package_+=(inferred_package_url)

	inferred_setup_+=(inferred_setup_architecture)
	inferred_setup_+=(inferred_setup_artifact)
	[[ "$inferred_setup_cpu" != 6809 ]] && inferred_setup_+=(inferred_setup_cpu)
	[[ "$inferred_setup_os9" != no ]] && inferred_setup_+=(inferred_setup_os9)
	[[ "$inferred_setup_ssc" != no ]] && inferred_setup_+=(inferred_setup_ssc)
	[[ "$inferred_setup_rtr" != no ]] && inferred_setup_+=(inferred_setup_rtr)
	inferred_setup_+=(inferred_setup_tv_type)
	[[ "$inferred_setup_cocovga" != no ]] && inferred_setup_+=(inferred_setup_cocovga)
	[[ "$inferred_setup_cocopsg" != no ]] && inferred_setup_+=(inferred_setup_cocopsg)
}

function infer_guess_dsk_command() { # file.dsk
#echo infer_guess_dsk_command "$@" >&2
	# return 0 of could guess, -1 if not
	# outputs: $command => command to load the disk

	# check if it is a OS-9/DOS disk
	dsk_load "$1"
	if [[ $dsk_format != "DECB" ]] ; then
		echo "DOS"
		return 0
	fi

	# PENDING - use direct acccess on disk and not DECB
	dsk_dir "$1" -BB >&2

	nfiles=${#dir[@]}
#echo NFILES = $nfiles >&2
#echo DIR: ${dir[@]} >&2
	# Empty disk
	if [ $nfiles == 0 ] ; then
		echo "PRINT\"EMPTY DiSK?\""
		return -1
	fi

	if [ $nfiles == 1 ] ; then
		# easy, only one file in the dir
		line=${dir[0]}
		file=$(echo "$line" | cut -d : -f 1)
		ext=$(echo "$line" | cut -d : -f 2)
#echo EXT $ext
		case $ext in
		BAS)
			echo "RUN\"$file\""
			return 0
			;;
		BIN)
			echo "LOADM\"$file\":EXEC"
			return 0
			;;
		*)
			command=""
			echo cannot infer: only one file that is not BAS nor BIN\($ext\)  >&2
			return -1
			;;
		esac
	fi

	PENDING # (3)
	# infer the command, inspecting the disk content
	# if there is a RUN.BAS / AUTOEXEC , run it.
	# If there is X.BIN & X.BAS run the BAS
	echo PENDING: more than one file that is not BAS nor BIN >&2
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
}

function infer_zip() { # file.zip outfile.autococo
#echo infer_zip "$@"
	WORKDIR="$WORKDIR/infer"
#echo WORKDIR "$WORKDIR"
echo "FILE: $1"
	unzip_at "$1" "$WORKDIR"

	pushd "$WORKDIR" > /dev/null

	# get all the DSKs files and sort the *BOOT.DSK first, then alphabetically.
	shopt -s nocaseglob
	shopt -s nullglob
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
#echo DISK $(basename "$disk") $i
		infer_dsk $(basename "$disk") $i
		i=$(($i+1))
	done
	popd > /dev/null
if [[ $i != 1 ]] ; then
  echo "  *** MORE THAN ONE DISK"
fi

#echo floppy: ${inferred_setup_floppy0}

#echo VARIABLES[]: ${!inferred_@}
	#rm -rf "$WORKDIR"
	return 0
}

function infer_dsk() { # file.dsk [number = 0]
#echo infer_dsk "$@"
	extension="${1##*.}"
	extension=${extension,,}
	if [[ "$extension" != "dsk" ]] ; then exit 1; fi

	number=${2:-0}
	declare -g "inferred_setup_floppy$number=$(basename \"$1\")"

	inferred_setup_+=(inferred_setup_floppy$number)

	if (( $number == 0 )) ; then 
		inferred_setup_command=`infer_guess_dsk_command "$disk"`
		if [[ $? != 0 ]] ; then
			echo "  *** CANNOT GUESS DSK COMMAND"
		fi
		inferred_setup_+=(inferred_setup_command)
	fi

	return 0
}

function infer_cas() { # file.dsk outfile.autococo
	extension="${1##*.}"
	extension=${extension,,}
	if [[ "$extension" != "cas" ]] ; then exit 1; fi

	inferred_setup_cassette=$(basename `$1`)

	PENDING # (1)

	#inferred_setup_command="CLOAD"
	inferred_setup_command="CLOADM"
	inferred_setup_+=(inferred_setup_command)

	return 0
}

function infer_ccc() { # file.ccc outfile.autococo
	extension="${1##*.}"
	extension="${extension,,}"
	if [[ "$extension" != "ccc" ]] && [[ "$extension" != "rom" ]] ; then exit 1; fi

	inferred_setup_rompack=$(basename "$1")
	inferred_setup_autorun=yes
	inferred_setup_+=(inferred_setup_rompack inferred_setup_autorun)

	return 0
}
