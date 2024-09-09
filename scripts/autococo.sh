#!/usr/bin/env bash
# Load config
if [[ -z "$SCRIPT_DIR" ]] ; then
	SCRIPT_DIR=`realpath .`/scripts
fi

#set -o errexit # exit on any error
#set -o nounset # script fail on unset variables
set -o pipefail # if some program in a pipa fails, aborts
if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi

if [ -f "$SCRIPT_DIR/autococo.config" ] ; then source "$SCRIPT_DIR/autococo.config" ; fi
if [ -f ~/.autococo ] ; then source ~/.autococo ; fi

if [ -d "$WORK_DIR" ] ; then rm -rf "$WORK_DIR" ; fi
if [ ! -d "$WORK_DIR" ] ; then mkdir -p "$WORK_DIR" ; fi

function debugfc() {
	local fn="$1"
	shift
	echo FUNCCALL: $fn\(\) "$@" >&2
}

function debug() {
	echo DEBUG: "$@" >&2
}

function error() {
	echo ERROR: "$@" >&2
}

source "$SCRIPT_DIR/yaml.sh"
source "$SCRIPT_DIR/database.sh"
source "$SCRIPT_DIR/util.sh"
source "$SCRIPT_DIR/zip.sh"
source "$SCRIPT_DIR/dsk.sh"
source "$SCRIPT_DIR/autococo.infer.sh"
source "$SCRIPT_DIR/autococo.download.sh"

function autococo_load() { # loads the autococo file in environment
       source <(parse_yaml "$1" coco_)
#       set | grep ^coco_ >&2
}

