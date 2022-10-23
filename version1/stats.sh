#!/bin/bash
source `dirname "$0"`/config.sh

DIR="$1"
KEY="$2"
TOTAL=0
declare -A results
while read file 
do
	LINE=`grep "$KEY:" "$file" | cut -d ":" -f 2-`
	VALUE=`trim "$LINE"`
	VALUE=${VALUE:-(unknown)}
	if [[ $VALUE == "(unknown)" ]] ; then
		echo $file
	fi
	COUNT=${results[$VALUE]}
	COUNT=${COUNT:-0}
	COUNT=$(($COUNT + 1))
	TOTAL=$(($TOTAL + 1))
	results[$VALUE]=$COUNT
done < <(find "$DIR" -name METAFILE.YML -print)

for key in "${!results[@]}"; do
    value=${results[$key]}
    echo "${key}: $value ($((100 * value / $TOTAL))%)"
done
echo "TOTAL: $TOTAL"
