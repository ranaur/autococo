#!/usr/bin/env bash

trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}


function decb() {
	DECB=`which decb`
	CMD="$1"
	DIRNAME=`dirname "$2"`
	DSKNAME=`basename "$2"`

	shift 2
	pushd "$DIRNAME" > /dev/null
	$DECB "$CMD" "$DSKNAME," "$@"
	RES=$?
	popd > /dev/null
	exit $RES
}

function error() {
        echo ERROR: $@ &> /dev/stderr
}

