#!/usr/bin/env bash

### MD File structure
# inferred__
# inferred_package_
#   inferred_package_author:
#   inferred_package_file:
#	inferred_package_genre:
#   inferred_package_language: English ...
#   inferred_package_md5:
#   inferred_package_year:
#   inferred_package_reference:
#   inferred_package_program:
#   inferred_package_url:
# inferred_setup_
#   inferred_setup_architecture: coco2 coco1 coco3
#   inferred_setup_artifact: no red blue
#   inferred_setup_command:
#   inferred_setup_cpu: 6809 6309
#   inferred_setup_floppy0
#   inferred_setup_dos: decb os9
#   inferred_setup_ssc: no required optional
#   inferred_setup_rtr: no required optional
#   inferred_setup_graphics:
#   inferred_setup_tv_type: ntsc pal pal50
#   inferred_setup_cocovga: no required
#   inferred_setup_cocopsg: no required
# CCC
#   inferred_setup_rompack: <file>

# infer package details from a cocoarchive file
#   Currently only works with ZIP file from Disks directory
#
function infer_archive_cocoarchive() {
#debugfc $FUNCNAME "$@"
	tags=()
	function has_tag() { # tag := returns 0 if there is the tag -1 otherwise
		[[ ":${tags[*]}:" =~ ":$1:" ]]
		return $?
	}
	function del_tag() { # tag
		#tags=(${tags[@]/$1})
		newtag=()
		for t in "${tags[@]}" ; do
			if [[ "$t" != "$1" ]] ; then
				newtag+=("$t")
			fi
		done
		tags=(${newtag[@]})

	}
	function has_del_tag() { # tag => returns of the tag exist, and removes it
		has_tag "$1"
		res=$?
		if [[ $res == 0 ]] ; then
			del_tag "$1"
		fi
		return $res
	}
	FULLFILEPATH=$(realpath "$1")

	DIRNAME=$(dirname "$FULLFILEPATH")
	inferred_package_+=(inferred_package_program)
		# will be guessed down below
	inferred_package_author=Unknown
		# will be guessed down below
	inferred_package_+=(inferred_package_author)


	inferred_package_genre=$(basename "$DIRNAME")
	inferred_package_+=(inferred_package_genre)

	inferred_package_file=`basename "$1"`
	inferred_package_+=(inferred_package_file)

	inferred_package_md5=$("$CMD_MD5SUM" "$FULLFILEPATH" | cut -b -32)
	inferred_package_+=(inferred_package_md5)

	inferred_package_program="${inferred_package_file%.*}"
	inferred_package_program="${inferred_package_program%% (*}"

	inferred_package_url="${FULLFILEPATH#*colorcomputerarchive.com/repo/}"
	inferred_package_url="https://colorcomputerarchive.com/repo/${inferred_package_url}"
	inferred_package_+=(inferred_package_url)

		# tags
	TAGS="${inferred_package_file#*(}"
	TAGS="${TAGS%.*}"
	 
	IFS=":"
	TAGLINE=$(echo "${TAGS}" | sed -e 's/(//g' -e 's/) /:/g' -e 's/)$//')
	read -a tags < <(echo "$TAGLINE")
#echo TAGS ORIGINAL ${#tags[@]}="(${tags[@]})"
	inferred_setup_architecture=coco2
	inferred_setup_+=(inferred_setup_architecture)
	has_del_tag "Coco 3" && inferred_setup_architecture=coco3
	has_del_tag "Coco 3 patch" && inferred_setup_architecture=coco3
	has_del_tag "Coco 3 enhancements" && inferred_setup_architecture=coco3
	has_del_tag "coco 3" && inferred_setup_architecture=coco3
	has_del_tag "Coco 1-2" && inferred_setup_architecture=coco1
#echo TAGS ${#tags[@]}="(${tags[@]})"

	has_del_tag "SSC" && inferred_setup_ssc=required && inferred_setup_+=(inferred_setup_ssc)
	has_del_tag "Real Talker required" && inferred_setup_rtr=required && inferred_setup_+=(inferred_setup_rtr)
	has_del_tag "CocoVGA" && inferred_setup_cocovga=required && inferred_setup_+=(inferred_setup_cocovga)
	has_del_tag "CoCo PSG" && inferred_setup_cocopsg=required && inferred_setup_+=(inferred_setup_cocovga)

	has_del_tag "PAL" && inferred_setup_tv_type=pal && inferred_setup_+=(inferred_setup_tv_type)
	has_del_tag "PAL 50Hz Coco 2" && inferred_setup_tv_type=pal50 && inferred_setup_+=(inferred_setup_tv_type) && inferred_setup_architecture=coco2
	has_del_tag "50hz" && inferred_setup_tv_type=pal50 && inferred_setup_+=(inferred_setup_tv_type) && inferred_setup_architecture=coco2
	has_del_tag "NTSC" && inferred_setup_tv_type=ntsc && inferred_setup_+=(inferred_setup_tv_type)

	has_del_tag "OS-9" && inferred_setup_dos=os9 && inferred_setup_+=(inferred_setup_dos)
	has_del_tag "RS-DOS" && inferred_setup_dos=rsdos && inferred_setup_+=(inferred_setup_dos)

	inferred_setup_cpu=6809
	has_del_tag "6309" && inferred_setup_cpu=6309 && inferred_setup_+=(inferred_setup_cpu)
	has_del_tag "6309 optimized" && inferred_setup_cpu=6309 && inferred_setup_+=(inferred_setup_cpu)
	has_del_tag "6309 compatible" && inferred_setup_cpu=6309 && inferred_setup_+=(inferred_setup_cpu)
	has_del_tag "6809 optimized" && inferred_setup_cpu=6809 && inferred_setup_+=(inferred_setup_cpu)

	has_del_tag "SG-8" && inferred_setup_graphics=SG-8 && inferred_setup_+=(inferred_setup_graphics)
	has_del_tag "SG-8 intro" && inferred_setup_graphics=SG-8i && inferred_setup_+=(inferred_setup_graphics)
	has_del_tag "SG-12" && inferred_setup_graphics=SG-12 && inferred_setup_+=(inferred_setup_graphics)
	has_del_tag "SG-12 intro" && inferred_setup_graphics=SG-12i && inferred_setup_+=(inferred_setup_graphics)
	has_del_tag "SG-24" && inferred_setup_graphics=SG-24 && inferred_setup_+=(inferred_setup_graphics)
	has_del_tag "SG-24 intro" && inferred_setup_graphics=SG-24i && inferred_setup_+=(inferred_setup_graphics)

	extratags=()
	known_tags=("2MB Patch" "fixed for 1 and 2MB RAM" "RGB Patch" "RGB patch" "Enhanced by sixxie" "alt" "Coco port" "Ports from ZX Spectrum" "Cheat" "Text" "Prototype" "Compatibility patch")
	for kt in "${known_tags[@]}" ; do
		has_del_tag "$kt" && extratags+="$kt"
	done
#echo TAGS ${#tags[@]}="(${tags[@]})"

	inferred_package_language=English
	has_del_tag "English translation" && extratags+=(Translation)
	has_del_tag "Portuguese" && inferred_package_language=Portuguese && inferred_package_+=(inferred_package_language)
	has_del_tag "Portuguse translation" && inferred_package_language=Portuguese && inferred_package_+=(inferred_package_language) && extratags+=(Translation)
	has_del_tag "Portuguese translation" && inferred_package_language=Portuguese && inferred_package_+=(inferred_package_language) && extratags+=(Translation)
	has_del_tag "Portuguese Translation" && inferred_package_language=Portuguese && inferred_package_+=(inferred_package_language) && extratags+=(Translation)
	has_del_tag "French" && inferred_package_language=French && inferred_package_+=(inferred_package_language)
	has_del_tag "French Translation" && inferred_package_language=French && inferred_package_+=(inferred_package_language) && extratags+=(Translation)
	has_del_tag "French translation" && inferred_package_language=French && inferred_package_+=(inferred_package_language) && extratags+=(Translation)

#echo TAGS ${#tags[@]}="(${tags[@]})"
	# search for special patterns
	for t in "${tags[@]}"
	do 
		if [[ "$t" =~ ^[0-9][0-9][0-9][0-9]$ ]] ; then
			inferred_package_year="$t"
			inferred_package_+=(inferred_package_year)
			del_tag "$t"
		fi
		if [[ "$t" =~ ^[0-9][0-9]-[0-9][0-9][0-9][0-9]$ ]] ; then
			inferred_package_reference="$t"
			inferred_package_+=(inferred_package_reference)
			del_tag "$t"
		fi
	done


	# infer the author
	if (( ${#tags[@]} == 0 )) ; then
		inferred_package_author="Unknown"
	else
		# assumes the last element is the author (should be the first?) 
		inferred_package_author="${tags[-1]}"
		unset tags[-1]
	fi

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

	inferred_setup_artifact=no
	inferred_setup_+=(inferred_setup_artifact)
	tags+=("${extratags[@]}")
	if [[ ${#tags[@]} != 0 ]] ; then
		inferred_package_tags="${tags[*]}"
		inferred_package_+=(inferred_package_tags)
	fi
}

function infer_guess_dsk_command() { # file.dsk
	# return 0 of could guess, -1 if not
	# outputs: $command => command to load the disk
#debugfc $FUNCNAME "$@"

	# check if it is a OS-9/DOS disk
	dsk_load "$1"
	if [[ $dsk_format != "DECB" ]] ; then
		echo "DOS"
		return 0
	fi

	dsk_dir "$1" -BB >&2
#debug ${dir[@]}
	nfiles=${#dir[@]}
#echo NFILES = $nfiles >&2
#echo DIR: ${dir[@]} >&2
	# Empty disk
	if [ $nfiles == 0 ] ; then
		echo "PRINT\"EMPTY DiSK?\""
		inferred_package_status="suspicious(empty disk)"
		return -1
	fi

#debug 3
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
			#echo cannot infer: only one file that is not BAS nor BIN\($ext\)  >&2
			return -1
			;;
		esac
	fi

	inferred_package_status="suspicious(cannot infer when there is more than one file)"
	# PENDING (3)
	# infer the command, inspecting the disk content
	# if there is a RUN.BAS / AUTOEXEC , run it.
	# If there is X.BIN & X.BAS run the BAS
	#echo PENDING: more than one file that is not BAS nor BIN >&2
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
#debugfc $FUNCNAME "$@"
	WORKDIR="$WORKDIR/infer"
#echo WORKDIR "$WORKDIR"
#echo "FILE: $1"
	unzip_at "$1" "$WORKDIR"

	pushd "$WORKDIR" > /dev/null

	# get all the DSKs files and sort the *BOOT.DSK first, then alphabetically.
	shopt -s nocaseglob
	shopt -s nullglob
	original_dsks=(*.DSK)
	dsks=()
	i=0
#echo ORIGINAL DSK = "${original_dsks[@]}" >&2

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
#echo DISK $(basename "$disk") $i >&2
		infer_dsk $(basename "$disk") $i
		i=$(($i+1))
	done
	popd > /dev/null
	if [[ $i != 1 ]] ; then
		inferred_package_status="suspicious(more than one disk)"
	fi

#echo floppy: ${inferred_setup_floppy0}

#echo VARIABLES[]: ${!inferred_@}
	#rm -rf "$WORKDIR"
	return 0
}

function infer_dsk() { # file.dsk [number = 0]
#debugfc $FUNCNAME "$@"
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
  			inferred_package_status="suspicious(icannot guess command)"
		fi
		inferred_setup_+=(inferred_setup_command)
	fi

	return 0
}

function infer_cas() { # file.dsk outfile.autococo
#debugfc $FUNCNAME "$@"
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
#debugfc $FUNCNAME "$@"
	extension="${1##*.}"
	extension="${extension,,}"
	if [[ "$extension" != "ccc" ]] && [[ "$extension" != "rom" ]] ; then exit 1; fi

	inferred_setup_rompack=$(basename "$1")
	inferred_setup_autorun=yes
	inferred_setup_+=(inferred_setup_rompack inferred_setup_autorun)

	return 0
}
