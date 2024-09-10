#!/bin/bash

_DIR="$(pwd)"
while [  "${_DIR}" = "/" ] ; 
do
	if [ -f "${_DIR}/.packages.config" ; then
		PACKAGES_DIR="${_DIR}"
		break;
	fi
	_DIR="$(dirname "${_DIR}")"
done

PACKAGES_DIR="${PACKAGES_DIR:-$HOME/packages}"
PACKAGES_CONF="${PACKAGES_DIR}/.packages.config"
PACKAGES_FILE="description.yaml"

source "$(dirname "$(realpath "$0")")/yaml.sh"
#echo PACKAGES_DIR=$PACKAGES_DIR
#echo PACKAGES_CONF=$PACKAGES_CONF

function _packages_findFile() {
	# _packages_findFile file
	# return file number fo the given file name
	# the package description must be loaded under prefix yaml_
	local filename="$1"
	local number=0
	
	for var in ${!yaml_files_*} ; do
		if [[ $var =~ ${prefix}_files_.*_name$ ]] ; then
			number="${var#yaml_files_}"
			number="${number%_name}"
			if [ ${!var} == "${filename}" ] ; then
				
				echo $number
				return 0
			fi
		fi
	done
	
	echo -1
	return 0
}

function packages_updateFile() {
	packages_setFileMetadata "$1" "$2" name
	packages_setFileMetadata "$1" "$2" creation
	packages_setFileMetadata "$1" "$2" size
	packages_setFileMetadata "$1" "$2" hash
}

function packages_getFileMetadata() {
#echo DEBUG: function call: $FUNCNAME\(#$#\) "$@"
	[ $# -ne 3 ] && return -1

	local package="$1"
	local file="$2"
	local metadata="$3"
	
	[ ! -f "${PACKAGES_DIR}/${package}/${file}" ] && echo "file not found" && return -2

	source <(load_yaml "${PACKAGES_DIR}/${package}/${PACKAGES_FILE}")

	local var="yaml_${file}_"
	local var_escaped="${var//./_}"
	
	filenumber=$(_packages_findFile "$file")
	if [ $filenumber -eq -1 ] ; then
		return 0
	fi

	local varprefix="files.$filenumber"
	get_yaml "$varprefix.$metadata"

	return 0
}

function packages_setFileMetadata() {
#echo DEBUG: function call: $FUNCNAME\(#$#\) "$@"
	[ $# -lt 3 ] && return -1

	local package="$1"
	local file="$2"
	local metadata="$3"
	local value="$4"
	
	[ ! -f "${PACKAGES_DIR}/${package}/${file}" ] && echo "file not found" && return -2

	source <(load_yaml "${PACKAGES_DIR}/${package}/${PACKAGES_FILE}")

	local var="yaml_${file}_"
	local var_escaped="${var//./_}"
	
	filenumber=$(_packages_findFile "$file")
	if [ $filenumber -eq -1 ] ; then # file does not exist in description yet
		source <(add_yaml files)
		filenumber=$LAST_ELEM
	fi

	local varprefix="files.$filenumber"

	if [ -z "$value" ] ; then
		case "$metadata" in
		name)
			value="$file"
			;;
		hash)
			value="md5:$(md5sum "${PACKAGES_DIR}/${package}/${file}" | cut -d\  -f1)"
			;;
		creation)
			value="$(date --reference="${PACKAGES_DIR}/${package}/${file}" '+%Y-%m-%d %H:%M:%S')"
			;;
		size)
			value="$(wc -c <"${PACKAGES_DIR}/${package}/${file}")"
			;;
		*)
			return -1 # value parameter is mandatory
			;;
		esac
	fi

	source <(set_yaml "$varprefix.$metadata" "$value")

	#list_yaml
	save_yaml "${PACKAGES_DIR}/${package}/${PACKAGES_FILE}"
	
	return 0
}

function packages_setMetadata() {
#echo DEBUG: function call: $FUNCNAME\(#$#\) "$@"
	[ $# -lt 3 ] || [ $# -gt 4 ] && return -1

	local package="$1"
	local prefix=${4:-yaml}
	local tag="${prefix}_${2//\./_}"
	local value="${3}"

	source <(parse_yaml "${PACKAGES_DIR}/${package}/${PACKAGES_FILE}" "${prefix}_")
	source <(echo $tag=\"$value\")

	#set | grep ^${prefix}
	save_yaml "${PACKAGES_DIR}/${package}/${PACKAGES_FILE}" "${prefix}"
	
	return 0
}

function packages_getMetadata() {
#echo DEBUG: function call: $FUNCNAME() "$@"
	[ $# -lt 2 ] || [ $# -gt 3 ] && return -1

	local package="$1"
	local prefix=${3:-yaml}
	local tag="${prefix}_${2//\./_}"

	source <(parse_yaml "${PACKAGES_DIR}/${package}/${PACKAGES_FILE}" "${prefix}_")
	echo ${!tag}

	return 0
}

function packages_setup() {
	[ $# -gt 1 ] && return -1
	[ $# -eq 1 ] && [ "$1" != -f ] && return -1
	[ "$1" = -f ] && local FORCE=yes

	if [ ! -d "${PACKAGES_DIR}" ] ; then
		mkdir -p "${PACKAGES_DIR}" || return 1
	fi

	if [ ! -f "${PACKAGES_CONF}" ] || [ "$FORCE" = yes ] ; then
		cat > "${PACKAGES_CONF}" << __DEFAULT_CONF__
__DEFAULT_CONF__
	fi

	return 0
}

function packages_removePackage() {
	local PACKAGE_NAME="$1"

	[ $# -ne 1 ] && return -1

	if [ ! -d "${PACKAGES_DIR}/${PACKAGE_NAME}" ] ; then
		echo Package does not exists
		return 1
	fi

	rm -rf "${PACKAGES_DIR}/${PACKAGE_NAME}"

	return $?
}

function packages_renamePackage() {
	local PACKAGE_NAME="$1"
	local NEW_PACKAGE_NAME="$2"

	[ $# -ne 2 ] && return -1

	if [ ! -d "${PACKAGES_DIR}/${PACKAGE_NAME}" ] ; then
		echo Package does not exists
		return 1
	fi

	mv "${PACKAGES_DIR}/${PACKAGE_NAME}" "${PACKAGES_DIR}/${NEW_PACKAGE_NAME}"

	packages_setMetadata "${NEW_PACKAGE_NAME}" package.name "${NEW_PACKAGE_NAME}"

	return $?
}

function packages_createPackage() {
	local PACKAGE_NAME="$1"

	[ $# -ne 1 ] && return -1

	if [ -d "${PACKAGES_DIR}/${PACKAGE_NAME}" ] ; then
		echo Package already exists
		return 1
	fi

	mkdir -p "${PACKAGES_DIR}/${PACKAGE_NAME}"
	cat > "${PACKAGES_DIR}/${PACKAGE_NAME}/${PACKAGES_FILE}" << __DEFAULT_PACKAGE__
package:
  name: ${PACKAGE_NAME}
  creation: $(date '+%Y-%m-%d %H:%M:%S')
__DEFAULT_PACKAGE__
	
	return 0
}

function packages_help() {
	case "$1" in
	setMetadata)
		cat << __
usage: $(basename "$0") $1 package tag metadata
sets a new value for a tag (create if it does not exists)
__
	;;
	getMetadata)
		cat << __
usage: $(basename "$0") $1 package tag
prints the current value for a tag
__
	;;
	setup)
		cat << __
usage: $(basename "$0") $1 [-f]
creates the packages directory using de default configuration
  -f - force creattion of package directory and configuration
__
	;;
	createPackage)
		cat << __
usage: $(basename "$0") $1 package
creates a new package
  package - name of the package
__
	;;
	removePackage)
		cat << __
usage: $(basename "$0") $1 package
removes a package
  package - name of the package
__
	;;
	renamePackage)
		cat << __
usage: $(basename "$0") $1 pacakge new_name
renames a package
  package - old name of the package
  new_name - new name of the package
__
	;;
	setFileMetadata)
		cat << __
usage: $(basename "$0") $1 pacakge file metadata [value]
Sets a metadata associated for the file. If the metadata is name, size, hash or creation, gets the value from the file.
Otherwise the fourth parameter is mandatory.
__
	;;
	getFileMetadata)
		cat << __
usage: $(basename "$0") $1 pacakge file metadata
Prints a metadata associated for the file.
__
	;;
	updateFile)
		cat << __
usage: $(basename "$0") $1 pacakge file
Sets name, size, hash and creation for file.
__
	;;
	*)
		cat << __HELP__
usage: $(basename "$0") command [parameters]
where command is:
  setMetadata - sets a metadata
  getMetadata - prints a metadata
  setup - setup the package directory
  createPackage - create new package
  removePackage - removes (deletes) a package
  renamePackage - renames a package
  setFileMetadata - sets a metadata for a file
  getFileMetadata - prints a metadata from a file
  updateFile - updats basic file info
  help - this message
__HELP__
	esac

	exit -1
}

# executes as command
if [ "$0" != "[${BASH_SOURCE[0]}]" ] ; then
	COMMAND=$1
	[ -z "$COMMAND" ] && packages_help
	shift
	case "$COMMAND" in
		setup|updateFile|getFileMetadata|setFileMetadata|renamePackage|removePackage|createPackage|getMetadata|setMetadata)
			"packages_$COMMAND" "$@"
			res=$?
			if [ $res -eq 255 ] ; then
				packages_help "$COMMAND"
			fi
			exit $res
		;;
		*)
			packages_help "$@"
		;;
	esac
fi

### Adding a new command
# Create help: text
# Create general help line
# Add in the ``case "$COMMAND" in`` - line
# Create the function
#


