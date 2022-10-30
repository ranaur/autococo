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
source "$SCRIPTDIR/download.sh"
source "$SCRIPTDIR/autococo.download.sh"
