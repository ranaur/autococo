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

XROAR=`which xroar`
if [[ ! -x "$XROAR" ]] ; then
	echo XROAR was not found in path
	exit -1
fi

coco_video_format="ANY"
source <(parse_yaml "$METAFILE" coco_)
#cat <(parse_yaml "$METAFILE" coco_)
#set | grep ^coco_

case "$coco_architecture" in
  coco1)
    MACHINE_ARCH=coco
    MACHINE_KEYBOARD=coco
    MACHINE_PALETTE=ideal
    BAS=bas14
    EXTBAS=extbas11
    VDG_TYPE=6847
    RAM=${coco_memory:-64}
    VDG_TYPE=6847
    ;;
  coco2)
    MACHINE_ARCH=coco
    MACHINE_KEYBOARD=coco
    MACHINE_PALETTE=ideal
    BAS=bas14
    EXTBAS=extbas11
    VDG_TYPE=6847t1
    RAM=${coco_memory:-64}
    ;;
  coco3)
    MACHINE_ARCH=coco3
    MACHINE_KEYBOARD=coco3
    MACHINE_PALETTE=ideal
    EXTBAS=coco3
    TV_INPUT=rgb
    VDG_TYPE=gime1986
    RAM=${coco_memory:-512}
    ;;
  *)
    echo "Unknown architecture $coco_architecture"
    exit 2
    ;;
esac

PROCESSOR=${coco_processor:-6809}

TV_TYPE=${coco_video_format:-any}
TV_TYPE=${TV_TYPE,,}
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

# XXX guess from the BIN size
#XXX ignore cartridge - remove from METAFILE if it is the default 
MACHINE_CART=rsdos


XROAR_PARAMS=()
[[ ! -z "$MACHINE" ]] && XROAR_PARAMS+=(-machine "${MACHINE}")
[[ ! -z "$MACHINE_ARCH" ]] && XROAR_PARAMS+=(-machine-arch "${MACHINE_ARCH}")
[[ ! -z "$MACHINE_KEYBOARD" ]] && XROAR_PARAMS+=(-machine-keyboard "${MACHINE_KEYBOARD}")
[[ ! -z "$PROCESSOR" ]] && XROAR_PARAMS+=(-machine-cpu "${PROCESSOR}")
[[ ! -z "$MACHINE_PALETTE" ]] && XROAR_PARAMS+=(-machine-palette "${MACHINE_PALETTE}")
[[ ! -z "$EXTBAS" ]] && XROAR_PARAMS+=(-extbas "${ROMDIR}/$EXTBAS.rom")
[[ ! -z "$TV_INPUT" ]] && XROAR_PARAMS+=(-tv-input "${TV_INPUT}")
[[ ! -z "$VDG_TYPE" ]] && XROAR_PARAMS+=(-vdg-type "${VDG_TYPE}")
[[ ! -z "$RAM" ]] && XROAR_PARAMS+=(-ram "${RAM}")
[[ ! -z "$TV_TYPE" ]] && XROAR_PARAMS+=(-tv-type "${TV_TYPE}")
[[ ! -z "$MACHINE_CART" ]] && XROAR_PARAMS+=(-machine-cart "${MACHINE_CART}")
if [[ ! -z "$coco_floppy0" ]] ; then XROAR_PARAMS+=(--load-fd0 "$coco_floppy0") ; fi
if [[ ! -z "$coco_floppy1" ]] ; then XROAR_PARAMS+=(--load-fd1 "$coco_floppy1") ; fi
if [[ ! -z "$coco_floppy2" ]] ; then XROAR_PARAMS+=(--load-fd2 "$coco_floppy2") ; fi
if [[ ! -z "$coco_floppy3" ]] ; then XROAR_PARAMS+=(--load-fd3 "$coco_floppy3") ; fi

#[[ ! -z "$coco_command" ]] && XROAR_PARAMS+=(-type "${coco_command}" -type "\r\n")

pushd "$DIR" > /dev/null
echo $XROAR "${XROAR_PARAMS[@]}" -type "${coco_command}" -type "\r\n" "$@"
$XROAR "${XROAR_PARAMS[@]}" -type "${coco_command}" -type "\r\n" "$@"
popd > /dev/null
exit 0
