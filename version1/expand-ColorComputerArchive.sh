#!/bin/bash

source `dirname "$0"`/config.sh


## USAGE
if [[ -z "$1" ]] ; then
	cat << __EOF__
usage: `basename $0` <file> <extra id>

	Expand <file> to <output dir> infering metata from file.
__EOF__
	exit 0
fi

## Find file in local diretory or in the archive
FULLNAME=`readlink -f "$1"`
if [[ ! -f "$FULLNAME" ]] ; then
	FULLNAME=`readlink -f "$ARCHIVE_DIR/colorcomputerarchive.com/repo/$1"`
fi

if [[ ! -f "$FULLNAME" ]] ; then
	echo ERROR: file "$1" not found in Color Computer Archive repository!
	exit -1
fi

PARTNAME=`realpath --relative-to="$ARCHIVE_DIR/colorcomputerarchive.com/repo/" "$FULLNAME"`

if [[ -z "$2" ]] ; then
	EXTRAID=""
else
	EXTRAID=" ($2)"
	shift
fi
## Guess some metadata base on name
URL="https://colorcomputerarchive.com/repo/$PARTNAME"

readarray -t -d / dirs < <(echo -n `dirname "$PARTNAME"`)

MEDIA=${dirs[0]}
GENRE=${dirs[1]}
EXTRA=${dirs[2]}
BASENAME=`basename "$PARTNAME"`
EXTENSION="${BASENAME##*.}"
FILENAME="${BASENAME%.*}"

function has_tag() {
	# has_tag (tag) filename
	if [[ "$2" == *"($1)"* ]] ; then
		echo true
	else
		echo false
	fi
}

function remove_tag() {
	# remove_tag (tag) filename
	echo ${2// ($1)/}
}

## Fix some typos on filenames
PROGRAM="$FILENAME"
PROGRAM="${PROGRAM/Real Talker required/Real Talker Required}"
PROGRAM="${PROGRAM/Sound-Speech cartridge required)/SSC}"

TAG="OS-9"; OS9=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="coco 3" ; COCO3LOW=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="Coco 3" ; COCO3=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="Coco 1-2" ; COCO1=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="SSC" ; SSC=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="Real Talker Required" ; RT=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="PAL" ; PAL=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="PAL 50Hz Coco 2" ; PAL50=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="NTSC" ; NTSC=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="6309 optimized" ; OPT6309=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="6309 compatible" ; COMP6309=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="6809 optimized" ; OPT6809=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="CocoVGA" ; COCOVGA=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="SG-8" ; SG8=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="SG-8 intro" ; SG8INTRO=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="SG-12" ; SG12=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="SG-12 intro" ; SG12INTRO=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="SG-24" ; SG24=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="SG-24 intro" ; SG24INTRO=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="CoCo PSG" ; COCOPSG=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="Enhanced by sixxie" ; SIXXIE=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="alt" ; ALT=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="Coco port" ; COCOPORT=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="English translation" ; ENGLISHTRANSLATION=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="Cheat" ; CHEAT=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="Text" ; TEXT=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="Ports from ZX Spectrum" ; PORTZX=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="Portuguese" ; PORTUGUESE=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="Portuguese Translation" ; PORTUGUESETRANSLATION=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="French" ; FRENCH=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="French Translation" ; FRENCHTRANSLATION=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="fixed for 1 and 2MB RAM" ; FIXED1N2MRAM=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`
TAG="50hz" ; HZ50=`has_tag "$TAG" "$PROGRAM"`; PROGRAM=`remove_tag "$TAG" "$PROGRAM"`

if [[ $COCO3LOW == true ]] ; then
	COCO3=true
	ALT=true
	unset COCORLOW
fi
## Guess Author and Program
if [[ "$PROGRAM" == *"("*")"* ]] ; then
	AUTHOR=${PROGRAM##*(} ; AUTHOR=${AUTHOR%)*}
else
	AUTHOR="Unknown Author"
fi

PROGRAM=${PROGRAM% (*)}

function fix_AUTHOR() {
	if [[ "$1" == "80 Micros Magazine" ]] ; then echo "80 Micro" ; exit 0 ; fi
	if [[ "$1" == "Aadvark-80" ]] ; then echo "Aardvark 80" ; exit 0 ; fi
	if [[ "$1" == "Aardvark-80" ]] ; then echo "Aardvark 80" ; exit 0 ; fi
	if [[ "$1" == "Aardvark" ]] ; then echo "Aardvark 80" ; exit 0 ; fi
	if [[ "$1" == " Anteco Software" ]] ; then echo "Anteco Software" ; exit 0 ; fi
	if [[ "$1" == "Anteco" ]] ; then echo "Anteco Software" ; exit 0 ; fi
	if [[ "$1" == "Burke & Burke" ]] ; then echo "Bruke & Burke" ; exit 0 ; fi
	if [[ "$1" == "Cable Soft" ]] ; then echo "Cable Software" ; exit 0 ; fi
	if [[ "$1" == "Chromassette" ]] ; then echo "Chromasette" ; exit 0 ; fi
	if [[ "$1" == "CLOAD" ]] ; then echo "CLOAD Publications Inc." ; exit 0 ; fi
	if [[ "$1" == "Cload" ]] ; then echo "CLOAD Publications Inc." ; exit 0 ; fi
	if [[ "$1" == "Coco Brothers Software" ]] ; then echo "CoCo Brothers Software" ; exit 0 ; fi
	if [[ "$1" == "CoCo Brothers" ]] ; then echo "CoCo Brothers Software" ; exit 0 ; fi
	if [[ "$1" == "Color Software" ]] ; then echo "Color Software Systems" ; exit 0 ; fi
	if [[ "$1" == "Colorquest" ]] ; then echo "ColorQuest" ; exit 0 ; fi
	if [[ "$1" == "Computerware"* ]] ; then echo "Computerware" ; exit 0 ; fi
	if [[ "$1" == "Eversoft Game" ]] ; then echo "Eversoft Games" ; exit 0 ; fi
	if [[ "$1" == "GOSUB Internatonal" ]] ; then echo "GOSUB International" ; exit 0 ; fi
	if [[ "$1" == "Hyper Tech Software" ]] ; then echo "Hyper-Tech Software" ; exit 0 ; fi
	if [[ "$1" == "Jade" ]] ; then echo "Jade Products" ; exit 0 ; fi
	if [[ "$1" == "Jim Gerrie's Games Collection" ]] ; then echo "Jim Gerrie" ; exit 0 ; fi
	if [[ "$1" == "Jim Gerrie's OS-9 L2 Games" ]] ; then echo "Jim Gerrie" ; exit 0 ; fi
	if [[ "$1" == "JR & JR Softstuff" ]] ; then echo "JR & JR Software" ; exit 0 ; fi
	if [[ "$1" == "Kouga" ]] ; then echo "Kouga Software" ; exit 0 ; fi
	if [[ "$1" == "Med Systems"* ]] ; then echo "Med Systems" ; exit 0 ; fi
	if [[ "$1" == "Mike Snyder's Games" ]] ; then echo "Mike Snyder" ; exit 0 ; fi
	if [[ "$1" == "Prickly Pear Software" ]] ; then echo "Prickly-Pear Software" ; exit 0 ; fi
	if [[ "$1" == "Quickbeam" ]] ; then echo "Quickbeam Software" ; exit 0 ; fi
	if [[ "$1" == "Royer Taylor" ]] ; then echo "Roger Taylor" ; exit 0 ; fi
	if [[ "$1" == "Saguaro Software" ]] ; then echo "Saguard Software" ; exit 0 ; fi
	if [[ "$1" == "Snailsoft" ]] ; then echo "Snailsoft Software" ; exit 0 ; fi
	if [[ "$1" == "Softek" ]] ; then echo "Softek International Limited" ; exit 0 ; fi
	if [[ "$1" == "Soft Sector Marketing" ]] ; then echo "Soft Sector Marketing Inc." ; exit 0 ; fi
	if [[ "$1" == "Spectral Associate" ]] ; then echo "Spectral Associates" ; exit 0 ; fi
	if [[ "$1" == "Sportsware" ]] ; then echo "SPORTSware" ; exit 0 ; fi
	if [[ "$1" == "SPORTware" ]] ; then echo "SPORTSware" ; exit 0 ; fi
	if [[ "$1" == "Sunfog Systems" ]] ; then echo "Sundog Systems" ; exit 0 ; fi
	if [[ "$1" == "Spectral Associates, L. Curtis Boyle" ]] ; then echo "Spectral Associates" ; exit 0 ; fi
	if [[ "$1" == "Tandy, Game Point Software" ]] ; then echo "Tandy" ; exit 0 ; fi
	if [[ "$1" == "Unknown author" ]] ; then echo "Unknown Author" ; exit 0 ; fi

	echo "$1"
	exit 0
}

ORIGAUTHOR="$AUTHOR"
AUTHOR=`fix_AUTHOR "$AUTHOR"`

# Guess Architecture/Video Format/Processor
ARCH=coco2
if [[ "$COCO3" == true ]] ; then ARCH=coco3 ; fi
if [[ "$COCO1" == true ]] ; then ARCH=coco3 ; fi

VIDEO_FORMAT=ANY
if [[ "$PAL" == true ]] ; then VIDEO_FORMAT=PAL ; fi
if [[ "$PAL50" == true ]] ; then VIDEO_FORMAT=PAL ; ARCH=coco2 ; fi
if [[ "$NTSC" == true ]] ; then VIDEO_FORMAT=NTSC ; fi

PROCESSOR=ANY
if [[ "$OPT6309" == true ]] ; then PROCESSOR=6309; fi
if [[ "$COMP6309" == true ]] ; then PROCESSOR=6309; fi
if [[ "$OPT6809" == true ]] ; then PROCESSOR=6809; fi

GRAPHIC_MODE=unknown
if [[ "$SG8" == true ]] ; then GRAPHIC_MODE=8; fi
if [[ "$SG8INTRO" == true ]] ; then GRAPHIC_MODE=8INTRO; fi
if [[ "$SG12" == true ]] ; then GRAPHIC_MODE=12; fi
if [[ "$SG12INTRO" == true ]] ; then GRAPHIC_MODE=12INTRO; fi
if [[ "$SG24" == true ]] ; then GRAPHIC_MODE=24; fi
if [[ "$SG24INTRO" == true ]] ; then GRAPHIC_MODE=24INTRO; fi

OS=RS-DOS
if [[ "$OS9" == true ]] ; then OS=OS9; fi

ARTIFACT=none
MEDIA=$MEDIA
SUBGENRE=unknown

LANGUAGE=english
if [[ "$ENGLISHTRANSLATION" == "true" ]] ; then LANGUAGE=english ; fi
if [[ "$PORTUGUESE" == "true" ]] ; then LANGUAGE=portuguese ; fi
if [[ "$PORTUGUESETRANSLATION" == "true" ]] ; then LANGUAGE=portuguese ; fi
if [[ "$FRENCH" == "true" ]] ; then LANGUAGE=french ; fi
if [[ "$FRENCHTRANSLATION" == "true" ]] ; then LANGUAGE=french ; fi

MORE=""
if [[ $ALT == true ]] ; then MORE=" (alt)" ; fi
if [[ $SSC == true ]] ; then MORE=" (SSC)" ; fi
if [[ $TEXT == true ]] ; then MORE=" (Text)" ; fi
if [[ $CHEAT == true ]] ; then MORE=" (Cheat)" ; fi
if [[ $FIXED1N2MRAM == true ]] ; then MORE=" (fixed for 1 and 2MB RAM)" ; fi
if [[ $PROCESSOR != ANY ]] ; then MORE=" ($PROCESSOR)" ; fi
if [[ $GRAPHIC_MODE != unknown ]] ; then MORE=" (SG-$GRAPHIC_MODE)" ; fi
if [[ $VIDEO_FORMAT != ANY ]] ; then MORE=" ($VIDEO_FORMAT)" ; fi

OUT_DIR="$PROGRAM_DIR/$GENRE/$AUTHOR/$PROGRAM/$MEDIA$MORE$EXTRAID"

if [[ -d "$OUT_DIR" ]] ; then
	echo "*** $PARTNAME"
	echo "    ERROR: Output directory for "$PARTNAME" already exist!"
	echo "    ERROR: dir = $OUT_DIR"
	exit 0
fi

mkdir -p "$OUT_DIR"

# generate YML FILE
cat > "$OUT_DIR/METAFILE.YML" << __EOF__
program: $PROGRAM
author: $AUTHOR
source: $URL
genre: $GENRE
subgenre: $SUBGENRE
language: $LANGUAGE
architecture: $ARCH
artifact: $ARTIFACT
OS: $OS
__EOF__
if [[ $PROCESSOR != "ANY" ]] ; then echo "processor: $PROCESSOR" >> "$OUT_DIR/METAFILE.YML" ; fi
if [[ $VIDEO_FORMAT != "ANY" ]] ; then echo "video_format: $VIDEO_FORMAT" >> "$OUT_DIR/METAFILE.YML" ; fi
if [[ $SSC == "true" ]] ; then echo "ssc: true" >> "$OUT_DIR/METAFILE.YML" ; fi
if [[ $RT == "true" ]] ; then echo "rt: true" >> "$OUT_DIR/METAFILE.YML" ; fi
if [[ $COCOVGA == "true" ]] ; then echo "cocovga: true" >> "$OUT_DIR/METAFILE.YML" ; fi
if [[ $COCOPSG == "true" ]] ; then echo "cocopsg: true" >> "$OUT_DIR/METAFILE.YML" ; fi
if [[ $GRAPHIC_MODE != "unknown" ]] ; then echo "graphic_mode: $GRAPHIC_MODE" >> "$OUT_DIR/METAFILE.YML" ; fi

# generate tag
echo "tags:" >> "$OUT_DIR/METAFILE.YML" 
if [[ $ALT == true ]] ; then echo "  alt" >> "$OUT_DIR/METAFILE.YML" ; fi
if [[ $COCOPORT == true ]] ; then echo "  CoCo_port" >> "$OUT_DIR/METAFILE.YML" ; fi
if [[ "$EXTRA" != "" ]] ; then echo "  $EXTRA" >> "$OUT_DIR/METAFILE.YML" ; fi
if [[ "$PORTZX" == true ]] ; then echo "  port_zx" >> "$OUT_DIR/METAFILE.YML" ; fi
if [[ "$HZ50" == true ]] ; then echo "  50Hz" >> "$OUT_DIR/METAFILE.YML" ; fi

orig_nocasematch=$(shopt -p nocasematch; true)
shopt -s nocasematch
case $EXTENSION in
  zip)
    expandZip "$FULLNAME" "$OUT_DIR" 

    # Generate disks info
    rest_cmd=$(shopt -p nocaseglob )  # Get restoration command
    shopt -s nocaseglob               # Set option
    DISK0=""
    diskNo=0
    for disk in "$OUT_DIR"/*.dsk ; do
        echo floppy${diskNo}: `basename "$disk"` >> "$OUT_DIR/METAFILE.YML"
        if [[ $diskNo == 0 ]] ; then
                DISK0="$disk"
        fi
        diskNo=$(($diskNo + 1))
    done
    ${rest_cmd}

    #guessCommandDSK $DISK0
    ;;
  ccc)
    cp "$FULLNAME" "$OUT_DIR" 
    echo "cartridge: "`basename "$FULLNAME"` >> "$OUT_DIR/METAFILE.YML"
    ;;
  cas)
    echo "****** NOT IMPLEMENTET YET"
    ;;
esac
$orig_nocasematch

exit 0
