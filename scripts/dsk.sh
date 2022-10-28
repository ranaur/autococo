DECB=`which decb`
if (( $? == 1 )) ; then exit -1; fi # decb not found

function dsk_load() { # FILENAME [DISK #]
	dsk_format=unknown
	FILESIZE=$(stat -c%s "$1")
	if [[ $FILESIZE == 161280 ]] ; then
		# A 35 track, 18 sector, 256 bytes Disk
		dsk_format=35TRACK
		dsk_offset=$((${2-0} * 161280))
		dsk_file="$1"

		# check format DOS/OS9
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
	dsk_readtrack="$1"
	dsk_readsector="$2"
	OFFSET=$(( $dsk_offset + 256 * ( ($dsk_readtrack * 18 ) + $dsk_readsector - 1 ) - 1 ))
#echo "od -vt x1 -N $SIZE -j "$OFFSET" "$FILE" | cut -b12- | tr ' \n'  ' ' | sed -e \"s/ //g\""
#echo FILEOFFSET $OFFSET FILESECTOR $(( $OFFSET / 256 ))
	dsk_sector=$(od -vt x1 -N 256 -j "$OFFSET" "$dsk_file" | cut -b12- | tr ' \n'  ' ' | sed -e "s/ //g")
	return $?
}

function dsk_getstring() { # pos [len = 1]
	len=${2:-1}
	realpos=$(($1 * 2))
	for ((i=1;i<=len;i++)); do
#echo len=$len realpos=$realpos >&2
		printf "\x${dsk_sector:$realpos:2}"
		realpos=$(($realpos + 2))
	done
}

function dsk_getbyte() { # pos
	realpos=$(($1 * 2))
#echo realpos=$realpos >&2
	printf $((16#${dsk_sector:$realpos:2}))
}

function dsk_getword() { # pos
	realpos=$(($1 * 2))
	fb=$((16#${dsk_sector:$realpos:2}))
	realpos=$(($realpos+2))
	lb=$((16#${dsk_sector:$realpos:2}))
	## little endian
	#echo $(($lb * 256 + $fb)) 
	# big endian
	echo $(($fb * 256 + $lb)) 
}

function dsk_readdirectory() {
	dsk_readsector 17 2
	dsk_fat=$dsk_sector

	dsk_files=()
	for s in {3..11} ; do
		# read a sector from a directory entries sector
		dir_status=0
		dsk_readsector 17 $s
		for e in {0..7} ; do
			offset=$(($e * 30))
#echo offset=$offset
			dir_status=`dsk_getbyte $(($offset + 0))`
			if [[ $dir_status == 0 ]] ; then
				# deleted entry
				continue
			fi
			if [[ $dir_status == 255 ]] ; then
				# last entry
				break
			fi

			declare -A entry
			entry[name]=`dsk_getstring $(($offset + 0)) 8`
			entry[extension]=`dsk_getstring $(($offset + 8)) 3`
			entry[type]=`dsk_getbyte $(($offset + 11))`
			entry[asciiflag]=`dsk_getbyte $(($offset + 12))`
			entry[firstgranule]=`dsk_getbyte $(($offset + 13))`
			entry[byteslastsector]=`dsk_getword $(($offset + 14))`
for val in "${!entry[@]}"; do echo $val=${entry[$val]}; done
			dir_files+=($entry)
		done
		if [[ $dir_status == 255 ]] ; then
			# last entry
			break
		fi
	done

#echo $dir_files[@]
}

function dsk_dumpdisk() {
	for t in {0..34} ; do
		for s in {1..18} ; do
			dsk_readsector $t $s;
			if [[ ! $dsk_sector =~ ^ff*$ ]] && [[ ! $dsk_sector =~ ^e5(e5)*$ ]] ; then
				echo TRACK $t SECTOR $s
printf  "FIRST 4 BYTES: \x${dsk_sector:0:2}\x${dsk_sector:1:2}\x${dsk_sector:2:2}\x${dsk_sector:3:2}\n" 
				echo $dsk_sector
				# | sed -e "s/^ff*$/(free)/"
				echo "";
			fi
		done; 
	done
}

function decb() {
        # floptool.exe flopdir input_format filesystem
        COMMAND="$1"
        FILE=`basename "$2"`
        DIR=`dirname "$2"`
        shift 2
        if [ ! -z "$DIR" ] ; then pushd "$DIR" > /dev/null ; fi
        "$DECB" "$COMMAND" "$FILE" "$@"
        if [ ! -z  "$DIR" ] ; then popd >  /dev/null ; fi
}


function dsk_dir() { # file [-BB = show only BIN and BAS files]
#echo dsk_dir "$@"
	dir=()
	out=$(decb dir "$1")
#echo OUT: "$out" 
#echo RET: $?
	files=$(echo "$out" | tail +3 | sort)
#echo RET: $?
#echo RAWFILES: "$files" 
#echo PARAM: $2
	if [ "$2" == "-BB" ] ; then
		files=$(echo "$files" | grep ".........BAS\|.........BIN")
	fi
	if [ "$2" == "-BAS" ] ; then
		files=$(echo "$files" | grep ".........BAS")
	fi
	if [ "$2" == "-BIN" ] ; then
		files=$(echo "$files" | grep ".........BIN")
	fi
	if [ ! -z "$2" ] && [ ${2:0:1} != '-' ] ; then
		files=$(echo "$files" | grep "$2")
	fi
#echo FILES: $files

	nfiles=$(echo "$files" | wc -l)
#echo nfiles: $nfiles
	if (( "$nfiles" == 0 )) ; then return 0; fi


	IFS="\n"	
	for line in "$files"
	do
#echo ":$line"

		filename=${line:0:8};
		filename=$(trim "$filename")
		ext=${line:9:3}
		ext=$(trim "$ext")
		fileext="$filename.$ext"
		type=${line:14:1}
			# type 0 = BASIC program 1 = BASIC data 2 = Machine-language 3=source file
		format=${line:17:1}
			# storage format A=ASCII B=BINARY
		length=${file:29:1}
			# in granules

		dir+=("$filename:$ext:$type:$format:$length:$fileext")
	done
	IFS=" "	
#echo DIR: $dir
}

