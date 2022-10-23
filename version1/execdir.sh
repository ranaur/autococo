#!/bin/bash

EDITOR=~/autococo/edit.sh
EXECUTOR=~/autococo/xroar.sh

for dir in * ; do
	echo "* $dir"
	for dir2 in "$dir"/* ; do
		echo "** $dir2"
		if [[ -d "$dir2" ]] ; then
			if grep -q "^status: working" "$dir2/METAFILE.YML" ; then
				echo "*** Skipping $dir2 because it is already working."
			else
				cat >> "$dir2/METAFILE.YML" << __EOF__
keyboard: ???
joystick: left,right,both
status: working?
__EOF__
			fi
				echo "*** Executing $dir2"
				"$EXECUTOR" "$dir2" >& /dev/null &
				EXEC_PID=$!
				"$EDITOR" "$dir2"
				wait $EXEC_PID
				read -t 2 -N 1 -p "Continue (Y/n)? " answer
				if [[ "${answer,,}" == 'n' ]] ; then
					exit 0
				fi
#			fi
		fi
	done
done
