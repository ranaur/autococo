#!/bin/bash

for t in programs/Games/*/*/* ; do
	echo "*** $t"
	./generateCommand.sh "$t"
done

