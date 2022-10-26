#!/bin/bash
# Load config
if [ -f "$SCRIPTDIR/autococo.config" ] ; then source "$SCRIPTDIR/autococo.config" ; fi
if [ -f ~/.autococo ] ; then source ~/.autococo ; fi

if [ -d "$WORKDIR" ] ; then rm -rf "$WORKDIR" ; fi
if [ ! -d "$WORKDIR" ] ; then mkdir -p "$WORKDIR" ; fi

source "$SCRIPTDIR/yaml.sh"
source "$SCRIPTDIR/database.sh"
source "$SCRIPTDIR/util.sh"
source "$SCRIPTDIR/zip.sh"
source "$SCRIPTDIR/dsk.sh"
source "$SCRIPTDIR/autococo.infer.sh"

function autococo_load() { # loads the autococo file in environment
	source <(parse_yaml "$1" coco_)
	#cat <(parse_yaml "$1" coco_)
	set | grep ^coco_
}

function autococo_infer_zip() {
	# generate the autococo metafile automagically from zipfile
	# FILE.ZIP AUTOCOCO.FILE
	if [ -z "$1" ] ; then return -1; fi
	if [ -z "$2" ] ; then return -1; fi

	ZIPFILE=`realpath "$1"`
	OUTFILE=`realpath "$2"`

	if [ ! -f "$ZIPFILE" ] ; then return -2; fi
	if [ -z "$OUTFILE" ] ; then return -2; fi

	unzip_at "$ZIPFILE" "$WORKDIR/zip"

	#rm -rf "$WORKDIR/zip"
}

