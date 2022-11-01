#!/usr/bin/env bash

function dsk_load() { # FILENAME [DISK #]
#debugfc $FUNCNAME "$@"
	dsk_format=unknown
	local filesize=$(stat -c%s "$1")
	if [[ $filesize == 161280 ]] ; then
		# A 35 track, 18 sector, 256 bytes Disk
		dsk_format=35TRACK
		dsk_offset=$((${2-0} * 161280))
		dsk_file="$1"

		# check format DOS/OS9 - first sector of directory track is normally empty (full of FFs)
		dsk_readsector 17 1
		if [[ $dsk_sector =~ ^ff*$ ]] ; then
			dsk_format=DECB
		else
			dsk_format=OS9
		fi
	fi

	# PENDING: read DMK format, other sizes

	if [[ dsk_format == unknown ]] ; then
		return 1;
	fi
	return 0;
}

function dsk_readsector() { # track sector
#debugfc $FUNCNAME "$@"
	dsk_readtrack="$1"
	dsk_readsector="$2"
	local offset=$(( $dsk_offset + 256 * ( ($dsk_readtrack * 18 ) + $dsk_readsector - 1 ) - 1 ))
#debug FILEOFFSET $offset FILESECTOR $(( $offset / 256 ))
	dsk_sector=$("$CMD_OD" -vt x1 -N 256 -j "$offset" "$dsk_file" | "$CMD_CUT" -b12- | "$CMD_TR" ' \n'  ' ' | "$CMD_SED" -e "s/ //g")
	return $?
}

function dsk_getstring() { # pos [len = 1]
	local len=${2:-1}
	local realpos=$(($1 * 2))
	local i
	for ((i=1;i<=len;i++)); do
#debug len=$len realpos=$realpos >&2
		"$CMD_PRINTF" "\x${dsk_sector:$realpos:2}"
		realpos=$(($realpos + 2))
	done
}

function dsk_getbyte() { # pos
#debugfc $FUNCNAME "$@"
	local realpos=$(($1 * 2))
#debug realpos=$realpos >&2
	"$CMD_PRINTF" $((16#${dsk_sector:$realpos:2}))
}

function dsk_getword() { # pos
#debugfc $FUNCNAME "$@"
	local realpos=$(($1 * 2))
	local fb=$((16#${dsk_sector:$realpos:2}))
	realpos=$(($realpos+2))
	lb=$((16#${dsk_sector:$realpos:2}))
	## little endian
	#echo $(($lb * 256 + $fb)) 
	# big endian
	echo $(($fb * 256 + $lb)) 
}

function dsk_readdirectory() { 
#debugfc $FUNCNAME "$@"
	dsk_readsector 17 2
	dsk_fat=$dsk_sector

	dir_name=()
	dir_extension=()
	dir_type=()
	dir_asciiflag=()
	dir_firstgranule=()
	dir_byteslastsector=()

	local s
	local e
	for s in {3..11} ; do
		# read a sector from a directory entries sector
		dir_status=0
		dsk_readsector 17 $s
		for e in {0..7} ; do
			offset=$(($e * 30))
#debug offset=$offset
			dir_status=`dsk_getbyte $(($offset + 0))`
			if [[ $dir_status == 0 ]] ; then
				# deleted entry
				continue
			fi
			if [[ $dir_status == 255 ]] ; then
				# last entry
				break
			fi

			declare -lA entry
			dir_name+=(`dsk_getstring $(($offset + 0)) 8`)
			dir_extension+=(`dsk_getstring $(($offset + 8)) 3`)
			dir_type+=(`dsk_getbyte $(($offset + 11))`)
			dir_asciiflag+=(`dsk_getbyte $(($offset + 12))`)
			dir_firstgranule+=(`dsk_getbyte $(($offset + 13))`)
			dir_byteslastsector+=(`dsk_getword $(($offset + 14))`)
		done
		if [[ $dir_status == 255 ]] ; then
			# last entry
			break
		fi
	done
}

function dsk_dumpdisk() {
#debugfc $FUNCNAME "$@"
	local t
	local s
	for t in {0..34} ; do
		for s in {1..18} ; do
			dsk_readsector $t $s;
			if [[ ! $dsk_sector =~ ^ff*$ ]] && [[ ! $dsk_sector =~ ^e5(e5)*$ ]] ; then
				echo TRACK $t SECTOR $s
#printf  "FIRST 4 BYTES: \x${dsk_sector:0:2}\x${dsk_sector:1:2}\x${dsk_sector:2:2}\x${dsk_sector:3:2}\n" 
				echo $dsk_sector
				# | "$CMD_SED" -e "s/^ff*$/(free)/"
				echo "";
			fi
		done; 
	done
}

function dsk_dir() { # file [-BB = show only BIN and BAS files]
#debugfc $FUNCNAME "$@"
	dsk_load "$1"
	if [[ $? != 0 ]] ; then return -1; fi
	shift
	dsk_readdirectory
	local includeentry
	local index

	dir=()
	for index in "${!dir_name[@]}"; do
		if [[ -z "$1" ]] ; then
			includeentry=true
		else
			if [[ "$1" == ${dir_extension[$index]} ]] ; then
				includeentry=true
			else
				includeentry=false
			fi
			if [[ "$1" == "-BB" ]] ; then
				if [[ ${dir_extension[$index]} == "BAS" ]] || [[ ${dir_extension[$index]} == "BIN" ]] ; then
					includeentry=true
				else
					includeentry=false
				fi
			fi
		fi

		if [[ "$includeentry" == true ]] ; then
			dir+=("${dir_name[$index]}:${dir_extension[$index]}:${dir_type[$index]}:${dir_asciiflag[$index]}:${dir_firstgranule[$index]}:${dir_name[$index]}.${dir_extension[$index]}")
		fi
	done

#debug DIR: ${dir[@]}
	return 0;
}

