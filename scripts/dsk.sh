DECB=`which decb`
if (( $? == 1 )) ; then exit -1; fi # decb not found

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
	files=$(decb dir "$1" | tail +3 | sort | tail -1)

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
#echo $files

	while read -r file
	do
		filename=${file%% *}
		file=${file:${#filename}}
		ext=${file:1:3}
		fileext=$(trim "$filename").$ext
		type=${file:3:1}
			# type 0 = BASIC program 1 = BASIC data 2 = Machine-language 3=source file
		format=${file:5:1}
			# storage format A=ASCII B=BINARY
		length=${file:16:1}
			# in granules

		dir+=("$filename:$ext:$type:$format:$length:$fileext")
	done < <(echo $files)
#echo DIR: $dir
}

