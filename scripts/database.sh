#!/bin/bash

if [ ! -d "$DATABASEDIR" ] ; then mkdir -p "$DATABASEDIR" ; fi

function database_filepath() {
	# prints the path for the file in the database based on the key
	KEY="$1" 
	WIDTH=${2:-$DATABASEWIDTH}

	if [ ${#KEY} -gt $DATABASEWIDTH ] ; then 
		PREFIX="${KEY:0:$DATABASEWIDTH}"
		echo "$DATABASEDIR/$PREFIX/$KEY"
	fi
}

function database_save() {
	# key file_to_save
	KEY="$1" 
	FILE="$2" 

	if [ -z "$KEY" ] ; then return -1; fi
	if [ -z "$FILE" ] ; then return -1; fi
	if [ ! -f "$FILE" ] ; then return -2; fi

	OUTFILE=`database_filepath "$KEY"`
	OUTDIR=`dirname "$OUTFILE"`

	mkdir -p "$OUTDIR"
	cp "$FILE" "$OUTFILE"

	return $?
}

function database_remove() {
	# key file_to_save
	KEY="$1" 

	if [ -z "$KEY" ] ; then return -1; fi
	OUTFILE=`database_filepath "$KEY"`

	# file does not exist
	if [ ! -f "$FILE" ] ; then return 0; fi

	rm "$OUTFILE"
	RES=$?
	# remove directory if it is the last file
	OUTDIR=`dirname "$OUTFILE"`
	rmdir "$OUTDIR" >& /dev/null

	return $RES
}
