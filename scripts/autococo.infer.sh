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
		inferred_package_status="inferred"
		return 0
	fi

	inferred_package_status="inferred with doubts (cannot infer)"

	dsk_dir "$1" BAS
	# Only one BAS file
	if [ ${#dir[@]} == 1 ] ; then
		local line=${dir[0]}
		local file=$(echo "$line" | cut -d : -f 1)
		echo "RUN\"$file\""
		inferred_package_status="inferred"
	fi

	# More than one BAS file
	if [ ${#dir[@]} -gt 1 ] ; then
		local file=""
		local diskname="${1##*.}"
		if containsElement "${diskname%[0-9]}" "${dir_name[@]}" ; then file="${diskname%[0-9]}.BAS" ; fi
		if containsElement "${diskname%[0-9]}" "${dir_name[@]}" ; then file="${diskname%[0-9][0-9]}.BAS" ; fi
		if containsElement "$diskname" "${dir_name[@]}" ; then file="$diskname.BAS" ; fi
		if containsElement "AUTOEXEC" "${dir_name[@]}" ; then file="AUTOEXEC.BAS" ; fi
		if containsElement "BOOT" "${dir_name[@]}" ; then file="BOOT.BAS" ; fi
		if containsElement "MENU" "${dir_name[@]}" ; then file="MENU.BAS" ; fi

		if [[ -z "$file" ]] ; then
			inferred_package_status="inferred with doubts (more than one BAS file)"
		else
			inferred_package_status="inferred with doubts (guessed $file)"
			echo "RUN\"$file\""
		fi
	fi

	# No BAS files, search for BIN files
	if [ ${#dir[@]} == 0 ] ; then
		dsk_dir "$1" BIN

		case ${#dir[@]} in
			0)	# no BIN files
				inferred_package_status="inferred with doubts (no BAS or BIN file)"
				;;
			1)
				inferred_package_status="inferred"
				local line=${dir[0]}
				local file=$(echo "$line" | cut -d : -f 1)
				echo "LOADM\"$file\":EXEC"
				;;
			*)
				local file=""
				local diskname="${1##*.}"
				if containsElement "${diskname%[0-9]}" "${dir_name[@]}" ; then file="${diskname%[0-9]}.BIN" ; fi
				if containsElement "${diskname%[0-9]}" "${dir_name[@]}" ; then file="${diskname%[0-9][0-9]}.BIN" ; fi
				if containsElement "$diskname" "${dir_name[@]}" ; then file="$diskname.BIN" ; fi
				if containsElement "AUTOEXEC" "${dir_name[@]}" ; then file="AUTOEXEC.BIN" ; fi
				if containsElement "BOOT" "${dir_name[@]}" ; then file="BOOT.BIN" ; fi
				if containsElement "MENU" "${dir_name[@]}" ; then file="MENU.BIN" ; fi

				if [[ -z "$file" ]] ; then
					inferred_package_status="inferred with doubts (more than one BIN file)"
				else
					inferred_package_status="inferred (guessed $file)"
					echo "LOADM\"$file\":EXEC"
				fi
				;;
		esac
	fi

	return 0
}

function infer_zip() { # file.zip outfile.autococo
#debugfc $FUNCNAME "$@"
	WORKDIR="$WORKDIR/infer"
	unzip_at "$1" "$WORKDIR"

	pushd "$WORKDIR" > /dev/null

	shopt -s nocaseglob
	shopt -s nullglob
	
	inferred_package_status="inferred with doubts (no file found)"
	# Look for CASs files inside ZIP file
	local files_cas=(*.CAS)
	case ${#files_cas} in
		0)	# no CAS files, ok
			;;
		1)	# one cas file, infer it
			infer_cas "${files_cas[0]}"
			;;
		*)	# mode than one file
			inferred_package_status="inferred with doubts (more than one CAS file)"
			;;
	esac

	# Look for DSKs files inside ZIP file
	# get all the DSKs files and sort the *BOOT.DSK first, then alphabetically.
	local files_dsk=(*.DSK)
#debug N_DSK=${#files_dsk[@]}
#debug DSKs="${files_dsk[@]}"
	case ${#files_dsk[@]} in
		0)	# no DSK files, ok
			;;
		1)	# only one DSK file, infer it
#debug FILE:"${files_dsk}"
			infer_dsk "${files_dsk}"
			;;
		*)	# mode than one file
			inferred_package_status="inferred with doubts (more than one CAS file)"
			local sorted_dsks

			IFS=$'\n' sorted_dsks=($(sort <<<"${files_dsk[*]}"))
			unset IFS

			#if containsElement "BOOT.DSK" "${files_dsk[@]}" ; then
			#	# put it in the first place
			#	sorted_dsks=( "${files_dsk[@]/BOOT.DSK}" )
			#	sorted_dsks=( "BOOT.DSK" "${files_dsk[@]}" )
			#fi

			local i=0
			local disk
			for disk in ${dsks[@]} ; do
#debug "infer_dsk($i)" $disk
				infer_dsk $(basename "$disk") $i
				i=$(($i+1))
			done
			if [[ $i != 1 ]] ; then
				inferred_package_status="inferred with doubts (more than one disk)"
			fi
			if [[ $i -gt 4 ]] ; then
				inferred_package_status="inferred with doubts (more than four disks)"
			fi
			;;
	esac

	popd > /dev/null

	#rm -rf "$WORKDIR"
	return 0
}

function infer_dsk() { # file.dsk [number = 0]
#debugfc $FUNCNAME "$@"
	local extension="${1##*.}"
	extension=${extension,,}
	if [[ "$extension" != "dsk" ]] ; then exit 1; fi

	local number=${2:-0}
	local disk=$(basename "$1")
	declare -g "inferred_setup_floppy$number=$(basename \"$1\")"

	inferred_setup_+=(inferred_setup_floppy$number)
	if (( $number == 0 )) ; then 
		inferred_setup_command=$(infer_guess_dsk_command "$disk")
		if [[ $? != 0 ]] ; then
  			inferred_package_status="inferred with doubts (cannot guess command)"
		fi
		inferred_setup_+=(inferred_setup_command)
	fi

	return 0
}

function infer_cas() { # file.dsk outfile.autococo
#debugfc $FUNCNAME "$@"
	local extension="${1##*.}"
	extension=${extension,,}
	if [[ "$extension" != "cas" ]] ; then exit 1; fi

	inferred_setup_cassette=$(basename `$1`)

	PENDING # (1) find out of if the file is BIN or BAS

	#inferred_setup_command="CLOAD"
	inferred_setup_command="CLOADM"
	inferred_setup_+=(inferred_setup_command)

	return 0
}

function infer_ccc() { # file.ccc outfile.autococo
#debugfc $FUNCNAME "$@"
	local extension="${1##*.}"
	extension="${extension,,}"
	if [[ "$extension" != "ccc" ]] && [[ "$extension" != "rom" ]] ; then exit 1; fi

	inferred_setup_rompack=$(basename "$1")
	inferred_setup_autorun=yes
	inferred_setup_+=(inferred_setup_rompack inferred_setup_autorun)

	return 0
}
