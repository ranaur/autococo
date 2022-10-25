# AUTOCOCO

Have you ever got a CoCo (Color Computer, TSR-80 Color, Dragon, CP-400 ...)  game by name, zipfile or .DSK and don't know how o use? How to load it? Which emulator parameter to use? And needed to google or ask for help? Autocoo is for you.

Autococo is a set of scripts to document a CoCo game in a structured format, so it can be used to load a game automatically in an CoCo emulator. At the same time the format (light YML, plaintext) is easy to read, so you can read and understand by yourself what is happening, or if you want to make ir run on a real hardware.

To load a coco Game it ahould be as easy as run:

	# autococo King.zip

# AUTCOCO Format

The AUTOCOCO format is very simple, just UTF-8 text files made by key-value pairs separated by a colon. So it is YML compliant. However, to be parsable by simples means, we don't use any indent or fancy options of a full YML file.

The allowed keys are:

1) metafile info

package:
  program: name of the program (Human readable)
  author: author of the program
  genre: [Games, Applications, Educational, Hardware, Programming, Utilities]
  file: name of the file:MD5
  url: https://colorcomputerarchive.com/repo/Disks/Games/Cashman (Computer Shack).zip
  md5: i32hdiuqwjhdblqskjh
  language: main laguage of the program: english, french, portuguese, etc.

setup:
  name: short name for the setup. Needed only if it as more than one setup
  description: textual description of the setup
  architecture: architecture, it can be: coco1 (16k), coco2 (64k), coco3 (128k) mayme more archtectures in the future
  memory: 16, 64, 128, 512, 1024, 2048 (defalt depends on architecture)
  cpu: [6809*, 6309] * should be 6309 if an Hitach 6309 is mandatory
  tv-type: [pal*, ntcs, pal-m] defaults to pal
  artifact: [none*, red, blue] default to none
  rompack: [file.ccc, @package ]  mount a ROM file as cartridge (or CCC file)
        if starts with a ! does not autorun
	// (not implemented) if starts  with @ it loads as a odule (@fd-502, @speech, etc.)
  cassette: mount a CAS file on cassete and rewind, if file ends with rw, nounts as write
MISSING: SD and HD
  floppy0: mount a DSK file on floppy 0, if file ends with :rw mounts as write
  floppy1: mount a DSK file on floppy 1
  floppy2: mount a DSK file on floppy 2
  floppy3: mount a DSK file on floppy 3
* joystcks: [left, right, both, none]
* keyboard: [keys]
  command: commant to run. If it sarts wih an @ it is a file

# Config files

	The config file is just a .SH file with some environment variables. It should be located at:

~/.autococo
scripts/autcoco.config

## Config variables
AUTOCOCODIR=Directory where autococo script is located
SCRIPTDIR=normaly $AUTOCOCODIR/scripts
DATABASEDIR=normaly $AUTOCOCODIR/database
WORKDIR=directory to extract/work files

## Infering program from name (Cocoarchive)
AUTHOR => Author of the program
PROGRAM => Program Name Inferred from file name
CATEGORY => Inferred by the Directory
SUBCATEGORY => Inferred by the Directory
URL => Infgerred by the path

FILENAME => only basename
MD5=MD5 of the file
MACHINE=if is is suitable for CoCo 1/2/3
SSC=yes/no Sound Speech Cartridge
RTR=yes/no Real Talker Required
VIDEO_FORMAT=NTSC/PAL/PAL 50Hz
OS9=yes/no Needs/Use OS-9
PROCESSOR=6809/6309
COCOVGA=yes/no needs CoCoVGA
SG=SG-8/SG-12/SG-24 +Intro => Semigraphics Mode (Intros)
SIXXIE=yes/no
ALT=yes/no Alternate version
COCOPORT=yes/no Port from other plattaform
LANGUAGE=English/Portuguese/French
TRANSLATION=yes/no if is a translation
CHEAT=yes/no it is a cheated version
TEXT=yex/no text version
PORT=COCO/ZXSPECTRUM


