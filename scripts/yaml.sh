#!/usr/bin/env bash

#function parse_yaml {
#   local prefix="$2"
#   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
#   sed -ne "s|^\($s\):|\1|" \
#        -ne 's|"|\\"|g' \
#        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
#        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" \
#	"$1" |
#   awk -F$fs '{
#      indent = length($1)/2;
#      vname[indent] = $2;
#      for (i in vname) {if (i > indent) {delete vname[i]}}
#      if (length("$3") > 0) {
#         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
#         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
#      }
#   }'
#}

source $SCRIPTDIR/parse_yaml.sh

function get_yaml() {
	# get_yaml FILE tag
	grep "^[\s]*$2:" "$1" | sed -e "s/^$2:[[:blank:]]*\(.*\)$/\1/"
}

function substitute_yaml() {
>&2 echo substitute_yaml "$@"
	# substitute_yaml FILE tag value
	if grep -q "$2" "$1" ; then
#>&2 echo FOUND
		sed -i "s/\($2: \).*\$/\1$3/" "$1"
	else # not found, append in the end
#>&2 echo NOT FOUND
		echo "$2": "$3" >> "$1"
	fi
}

function save_yaml_() {
#echo save_yaml_ "$@"
	PREFIX="$1"
	FILE="$2"
	VAR="${3}[@]"
	IN=${4:-0}

	if (( $IN == 0 )) ; then
		INDENT=""
	else
		INDENT=`for i in {1..$4}; do echo -n " "; done`
	fi

	for item in "${!VAR}" ; do
		if [[ -z "${!item}" ]] ; then
			echo "$INDENT${item#"$PREFIX"_}:" >> "$FILE"
			echo $(save_yaml_ "$PREFIX_$item" "$FILE" "$item"_ $((1+IN))) > /dev/null
		else
			echo "$INDENT${item#"$PREFIX"_}: ${!item}" >> "$FILE"
		fi
		##echo "save_yaml_ \"$PREFIX_$item\" \"$FILE\" \"$item\"_ $((1+$IN))"
	done
}

# save_yaml => prefix file +> save all variables from YAML file to a YAML file. Opposite from parse_yaml
function save_yaml() {
#echo save_yaml "$@"
	PREFIX="$1"
	FILE="$2"

	cat < /dev/null > "$FILE"

	#export ${!$PREFIX_@}
	save_yaml_ "$PREFIX" "$FILE" "${PREFIX}__"
}

export -f save_yaml_
