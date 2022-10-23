#!/bin/sh

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

source $(dirname "$0")/scripts/parse_yaml.sh

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

