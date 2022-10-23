#!/bin/bash

for t in * ; do ls -1 "$t" | wc | cut -b -8 | xargs echo -n ; echo " $t" ; done > progs_per_author
