#!/bin/bash

for t in archive/colorcomputerarchive.com/repo/Disks/Games/* ; do
	# echo '*********************************************************************************************************'
	#echo "*** $t"
	if [[ ! -d "$t" ]] ; then
		./expand-ColorComputerArchive.sh "$t"
	fi
done
./expand-ColorComputerArchive.sh "Disks/Games/Color Computer Clue (LDG Free Software).zip" "Coco 1-2"
./expand-ColorComputerArchive.sh "Disks/Games/Draw Poker (T&D Software).zip" "Coco 1-2"
./expand-ColorComputerArchive.sh "Disks/Games/Poker Squares (Paul Shoemaker) (CocoVGA) (Coco 1-2).zip" "CocoVGA"
./expand-ColorComputerArchive.sh "Disks/Games/Poker Squares (Paul Shoemaker).zip" "Coco 1-2"
./expand-ColorComputerArchive.sh "Disks/Games/Strip Poker (Artworx) (OS-9) (Coco 3).zip" OS-9
./expand-ColorComputerArchive.sh "Disks/Games/Zonerunner (Tandy) (OS-9) (Coco 3).zip" OS-9

