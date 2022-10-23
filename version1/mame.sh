#!/bin/bash
ROMDIR=/media/share1/roms

source `dirname "$0"`/config.sh

if [[ -z "$1" ]] ; then
	cat << __EOF__
usage: `basename $0` <dir>

	Execute the CoCo program on the given directory
__EOF__
	exit 0
fi

if [[ "$1" == "-e" ]] ; then
	EDIT=true
	shift
else
	EDIT=false
fi

DIR="$1"

if [[ ! -f "$DIR/METAFILE.YML" ]] ; then
	DIR="$1/Disks"
fi

METAFILE="$DIR/METAFILE.YML"

if [[ ! -f "$METAFILE" ]] ; then
	echo METAFILE.YML was not found in $DIR
	exit -1
fi

shift

if [[ "$EDIT" == true ]] ; then
	vi "$METAFILE"
	exit $?
fi

MAME=`which mame`
if [[ ! -x "$MAME" ]] ; then
	echo MAME was not found in path
	exit -1
fi

coco_video_format="ANY"
source <(parse_yaml "$METAFILE" coco_)
#cat <(parse_yaml "$METAFILE" coco_)
TV_TYPE=${coco_video_format:-any}
TV_TYPE=${TV_TYPE,,}

case "$coco_architecture" in
  coco1)
    # coco cocoe
    MAME_SYSTEM=cocoe
    [[ "$PROCESSOR" == 6309 ]] && MAME_SYSTEM=${MAME_SYSTEM}h
    RAM=${coco_memory:-64}
    ;;
  coco2)
    # coco2 coco2b
    MAME_SYSTEM=coco2
    MAME_OPTIONS=
    [[ "$PROCESSOR" == 6309 ]] && MAME_SYSTEM=${MAME_SYSTEM}h
    RAM=${coco_memory:-64}
    ;;
  coco3)
    # coco3 coco3p
    MAME_SYSTEM=coco3
    [[ "$PROCESSOR" == 6309 ]] && MAME_SYSTEM=${MAME_SYSTEM}h
    RAM=${coco_memory:-512}
    ;;
  *)
    echo "Unknown architecture $coco_architecture"
    exit 2
    ;;
esac

PROCESSOR=${coco_processor:-6809}

if [[ "$TV_TYPE" == "any" ]] ; then TV_TYPE=ntsc ; fi
TV_INPUT=${TV_INPUT:-cmp-br}
case $coco_artifact in
	blue-red)
	TV_INPUT=cmp-br
	;;
	red-blue)
	TV_INPUT=cmp-rb
	;;
	none)
	TV_INPUT=cmp
	;;
esac

MAME_OPTIONS=("-skip_gameinfo" "-ui_mouse")

MAME_MEDIA=()
if [[ ! -z "$coco_floppy0" ]] ; then MAME_MEDIA+=("-flop1" "$coco_floppy0") ; fi
if [[ ! -z "$coco_floppy1" ]] ; then MAME_MEDIA+=("-flop2" "$coco_floppy1") ; fi

MAME_SOFTWARE=""
pushd "$DIR" > /dev/null
$MAME "$MAME_SYSTEM" "${MAME_MEDIA[@]}" $MAME_SOFTWARE "${MAME_OPTIONS[@]}" -autoboot_delay 3 -autoboot_command "${coco_command}\n" "$@"
popd > /dev/null
exit 0
