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

source "$(dirname "$(realpath "$0")")/parse_yaml.sh"
function list_yaml() {
	set | grep ^${1:-yaml}_
}

function load_yaml() {
	parse_yaml "$1" "${2:-yaml}_"
}

function get_yaml() {
#>&2 echo debug: $FUNCNAME "$@"
	# yaml must be loaded
	local var="$1"
	local prefix="${2:-yaml}"

	[ $? -ge 2 ] && return -1

	local envvar="${prefix}_${var//./_}"

	echo ${!envvar}

	return 0
}

function substitute_yaml() {
#>&2 echo substitute_yaml "$@"
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
#1>&2 echo save_yaml_ "$@"
	local PREFIX="$1"
	local FILE="$2"
	local VAR="${3}[@]"
	local IN=$4
	local INDENT
	
	if (( $IN == 0 )) ; then
		INDENT=""
	else
		printf -v INDENT '%*s' $((IN * 2)) ''
		#INDENT="$(for i in {1..$IN}; do echo -n "  "; done)"
	fi
#1>&2 echo LEN IN $IN IDENT ${#INDENT}

	for item in ${!VAR} ; do
		if [[ $item =~ .*[0-9]+$ ]] ; then # array
#1>&2 echo ARRAY $item
			echo "$INDENT- " >> "$FILE"
			save_yaml_ "$PREFIX_$item" "$FILE" "$item"_ $((1+IN)) > /dev/null
		else 
			if [[ -z "${!item}" ]] ; then
#1>&2 echo HASH $item -z $PREFIX
				echo "$INDENT${item#"$PREFIX"_}:" >> "$FILE"
				save_yaml_ "$PREFIX_$item" "$FILE" "$item"_ $((1+IN)) > /dev/null
			else
#1>&2 echo HASH $item !-z
				echo "$INDENT${item#"$PREFIX"_}: ${!item}" >> "$FILE"
			fi
		fi
		##echo "save_yaml_ \"$PREFIX_$item\" \"$FILE\" \"$item\"_ $((1+$IN))"
	done
}

# save_yaml => prefix file +> save all variables from YAML file to a YAML file. Opposite from parse_yaml
function save_yaml() {
#echo save_yaml "$@"
	local file="$1"
	local prefix="${2:-yaml}"

	cat < /dev/null > "$file"

	#export ${!$prefix_@}
	save_yaml_ "$prefix" "$file" "${prefix}__" 0
}

export -f save_yaml_

function set_yaml() {
	# usage: source <(set_yaml variable.var value [prefix])
	# set_yaml var value [prefix]
	local var="${1}"
	local value="${2}"
	local prefix="${3:-yaml}"
	local lastvar="${var##*.}"

	#echo var=$var prefix=$prefix lastvar=$lastvar
	
	local varname="${prefix}_${var//./_}"
	#local varholder="$(sed -e "s/$lastvar\$//" <<< $varname)"
	local varholder="${varname%%$lastvar}"
	#echo varname=$varname varholder=$varholder
	
	if [[ ! "${!varholder}" =~ " $varname" ]] ; then
		echo "${varholder}='${!varholder} $varname'"
	fi
	echo "${varname}='${value}'"
}

function del_yaml() {
	# usage: source <(del_yaml variable.var [prefix])
	# del_yaml var value [prefix]
	local var="${1}"
	local prefix="${2:-yaml}"
	local lastvar="${var##*.}"

	local varname="${prefix}_${var//./_}"
	local varholder="${varname%%$lastvar}"
	#echo varname=$varname varholder=$varholder
	
	if [[ "${!varholder}" =~ " $varname" ]] ; then
		local varholdervalue="${!varholder}"
		varholdervalue="${varholdervalue/ $varname}"
		echo "${varholder}='${varholdervalue}'"
	fi
}

function add_yaml() {
	# usage: source <(add_yaml variable.var [prefix])
	# add_yaml var.array [prefix]
	local var="${1}"
	local prefix="${2:-yaml}"
	local lastvar="${var##*.}"
	local varname="${prefix}_${var}_"
	local varholder="${varname%%$lastvar}"
	#echo varname=$varname varholder=$varholder

	local nelem=0
	for t in ${!varholder} ; do
		local idx="${t/$varholder}"

		if [[ ! "$idx" =~ ^[0-9]+$ ]] ; then
			1>&2 echo "variable is not an array"
			return -1
		fi
		
		if [[ $idx -gt $nelem ]] ; then
			nelem=$(($idx))
		fi
	done
	nelem=$(($nelem + 1))

	echo "${varholder}='${!varholder} ${varname}$nelem'"
	echo LAST_ELEM_VAR="${var}.$nelem"
	echo LAST_ELEM=$nelem
}
