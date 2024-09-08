#!/usr/bin/env bash
ROMDIR=/media/share1/roms

XROAR=`which xroar`
if [[ ! -x "$XROAR" ]] ; then
	echo XROAR was not found in path
	exit -1
fi

XROAR_MACHINE_CART=rsdos
XROAR_PARAMS=()
case $coco_setup_architecture in
	coco1)
		XROAR_MACHINE=coco
		XROAR_MACHINE_ARCH=coco
		XROAR_MACHINE_KEYBOARD=coco
		XROAR_MACHINE_PALETTE=ideal
		XROAR_BAS=bas13
		XROAR_EXTBAS=extbas10
		XROAR_VDG_TYPE=6847
		XROAR_RAM=${coco_setup_memory:-16}
		XROAR_VDG_TYPE=6847
		;;
	coco2)
		XROAR_MACHINE_ARCH=coco2b
		XROAR_MACHINE_KEYBOARD=coco
		XROAR_MACHINE_PALETTE=ideal
		XROAR_BAS=bas13
		XROAR_EXTBAS=extbas11
		XROAR_VDG_TYPE=6846t1
		XROAR_RAM=${coco_setup_memory:-64}
		;;
	coco3)
		XROAR_MACHINE_ARCH=coco3
		XROAR_MACHINE_KEYBOARD=coco3
		XROAR_MACHINE_PALETTE=ideal
		XROAR_BAS=coco3
		XROAR_EXTBAS=coco3
		XROAR_TV_INPUT=rgb
		XROAR_VDG_TYPE=gime1985
		XROAR_RAM=${coco_setup_memory:-128}
		;;
	*)
		echo "Unknown architecture $coco_setup_architecture"
		exit 2
		;;
esac

[[ ! -z "$XROAR_MACHINE" ]] && XROAR_PARAMS+=(-machine "$XROAR_MACHINE")
[[ ! -z "$XROAR_MACHINE_ARCH" ]] && XROAR_PARAMS+=(-machine "$XROAR_MACHINE_ARCH")
#[[ ! -z "$XROAR_MACHINE_KEYBOARD" ]] && XROAR_PARAMS+=(-machine-keyboard "$XROAR_MACHINE_KEYBOARD")
XROAR_MACHINE_CPU=${coco_setup_cpu:-6809}
[[ ! -z "$XROAR_MACHINE_CPU" ]] && XROAR_PARAMS+=(-machine-cpu "$XROAR_MACHINE_CPU")
[[ ! -z "$XROAR_BAS" ]] && XROAR_PARAMS+=(-bas "$XROAR_BAS")
[[ ! -z "$XROAR_EXTBAS" ]] && XROAR_PARAMS+=(-extbas "$XROAR_EXTBAS")
if [[ "$coco_setup_tv_type" == "any" ]] ; then coco_setup_tv_type=ntsc ; fi
[[ ! -z "$XROAR_TV_TYPE" ]] && XROAR_PARAMS+=(-tv-type "$coco_setup_tv_type")
[[ ! -z "$XROAR_RAM" ]] && XROAR_PARAMS+=(-ram "$XROAR_RAM")

case $coco_setup_artifact in
	red)
		XROAR_TV_INPUT=cmp-rb
		;;
	blue)
		XROAR_TV_INPUT=cmp-br
		;;
	no)
		XROAR_TV_INPUT=cmp
		;;
	rgb)
		XROAR_TV_INPUT=rgb
		;;
esac
[[ ! -z "$XROAR_TV_INPUT" ]] && XROAR_PARAMS+=(-tv-input "$XROAR_TV_INPUT")

if [ ! -z "$coco_setup_rompack" ] ; then
	if [ ${coco_setup_rompack:0:1} == '!' ] ; then
		XROAR_PARAMS+=(-load "${coco_setup_rompack:1}")
	else
		XROAR_PARAMS+=(-run "${coco_setup_rompack}")
	fi
fi

if [ ! -z "$coco_setup_cassette" ] ; then
	if [ ${coco_setup_cassette:0:1} == '!' ] ; then
		XROAR_PARAMS+=(-tape-write "${coco_setup_cassette:1}")
	else
		XROAR_PARAMS+=(-load-tape "${coco_setup_cassette}")
	fi
fi

if [ ! -z "$coco_setup_floppy0" ] ; then
	XROAR_MACHINE_CART=rsdos
	if [ "${coco_setup_floppy0:0:1}" == '!' ] ; then
		XROAR_PARAMS+=(-load-fd0 "${coco_setup_floppy0:1}")
		XROAR_DISK_WRITE=true
	else
		XROAR_PARAMS+=(-load-fd0 "${coco_setup_floppy0}")
	fi
fi

if [ ! -z "$coco_setup_floppy1" ] ; then
	XROAR_MACHINE_CART=rsdos
	if [ "${coco_setup_floppy1:0:1}" == '!' ] ; then
		XROAR_PARAMS+=(-load-fd1 "${coco_setup_floppy1:1}")
		XROAR_DISK_WRITE=true
	else
		XROAR_PARAMS+=(-load-fd1 "${coco_setup_floppy1}")
	fi
fi

if [ ! -z "$coco_setup_floppy2" ] ; then
	XROAR_MACHINE_CART=rsdos
	if [ "${coco_setup_floppy2:0:1}" == '!' ] ; then
		XROAR_PARAMS+=(-load-fd2 "${coco_setup_floppy2:1}")
		XROAR_DISK_WRITE=true
	else
		XROAR_PARAMS+=(-load-fd2 "${coco_setup_floppy2}")
	fi
fi

if [ ! -z "$coco_setup_floppy3" ] ; then
	XROAR_MACHINE_CART=rsdos
	if [ "${coco_setup_floppy3:0:1}" == '!' ] ; then
		XROAR_PARAMS+=(-load-fd3 "${coco_setup_floppy3:1}")
		XROAR_DISK_WRITE=true
	else
		XROAR_PARAMS+=(-load-fd3 "${coco_setup_floppy3}")
	fi
fi

if [ "$XROAR_DISK_WRITE" == "true" ] ; then XROAR_PARAMS+=(-disk-write-back) ; fi

if [ ! -z "$coco_setup_command" ] ; then
	if [ "${coco_setup_command:0:1}" == '@' ] ; then
		XROAR_PARAMS+=(-load-text "${coco_setup_command:1}")
	else
		XROAR_PARAMS+=(-type "${coco_setup_command}" -type "\r\n")
	fi
fi

#XROAR_PARAMS+=(-machine-cart $XROAR_MACHINE_CART)

#echo WORK_DIR: $WORK_DIR
[[ ! -z "$WORK_DIR" ]] && pushd "$WORK_DIR" > /dev/null

echo $XROAR "${XROAR_PARAMS[@]}" "$@"

"$XROAR" "${XROAR_PARAMS[@]}" -type "${coco_setup_command}" -type "\r\n" "$@"
RES=$?

[[ ! -z "$WORK_DIR" ]] && popd > /dev/null

exit $?
