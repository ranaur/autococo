DECB=`which decb`
function decb() { #  flopdir input_format filesystem
echo function decb "$@"
        COMMAND="$1"
        FILE=`basename "$2"`
        DIR=`dirname "$2"`
        shift 2
        pushd "$DIR" > /dev/null
        "$DECB" "$COMMAND" "$FILE" "$@"
        popd >  /dev/null
}


