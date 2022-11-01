#!/usr/bin/env bash
# Load config
if [[ -z "$SCRIPTDIR" ]] ; then
	SCRIPTDIR=`realpath .`/scripts
fi

#set -o errexit # exit on any error
#set -o nounset # script fail on unset variables
set -o pipefail # if some program in a pipa fails, aborts
if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi

if [ -f "$SCRIPTDIR/autococo.config" ] ; then source "$SCRIPTDIR/autococo.config" ; fi
if [ -f ~/.autococo ] ; then source ~/.autococo ; fi

if [ -d "$WORKDIR" ] ; then rm -rf "$WORKDIR" ; fi
if [ ! -d "$WORKDIR" ] ; then mkdir -p "$WORKDIR" ; fi

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

source "$SCRIPTDIR/yaml.sh"
source "$SCRIPTDIR/database.sh"
source "$SCRIPTDIR/util.sh"
source "$SCRIPTDIR/zip.sh"
source "$SCRIPTDIR/dsk.sh"
source "$SCRIPTDIR/autococo.infer.sh"
source "$SCRIPTDIR/autococo.download.sh"
