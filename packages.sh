#!/bin/bash

_DIR="$(pwd)"
while [  "${_DIR}" = "/" ] ; 
do
	if [ -f "${_DIR}/.packages.config" ; then
		PACKAGES_DIR="${_DIR}"
		break;
	fi
	_DIR=$(dirname "${_DIR}")
done

PACKAGES_DIR="${PACKAGES_DIR:-$HOME/packages}"
PACKAGES_CONF="${PACKAGES_DIR}/.packages.config"

echo PACKAGES_DIR=$PACKAGES_DIR
echo PACKAGES_CONF=$PACKAGES_CONF

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

function packages_create() {
	local PACKAGE_NAME="$1"

	[ $# -ne 1 ] && return -1
	[ -z "${PACKAGE_NAME}" ] && return -1

	if [ -d "${PACKAGES_DIR}/${PACKAGE_NAME}" ] ; then
		echo Package already existis
		return 1
	fi

	mkdir -p "${PACKAGES_DIR}/${PACKAGE_NAME}"
	cat > "${PACKAGES_DIR}/${PACKAGE_NAME}/description.yaml" << __DEFAULT_PACKAGE__
package:
  name: ${PACKAGE_NAME}
  creation: $(date '+%Y-%m-%d %H:%M:%S')
__DEFAULT_PACKAGE__
	
	return 0
}

function packages_help() {
	case "$1" in
	setup)
		cat << __SETUP__
usage: $(basename "$0") $1 [-f]
creates the packages directory using de default configuration
  -f - force creattion of package directory and configuration
__SETUP__
	;;
	create)
		cat << __CREATE__
usage: $(basename "$0") $1 "pacakge_name"
creates a new package
  "package name" - name of the package
__CREATE__
	;;
	*)
		cat << __HELP__
usage: $(basename "$0") command [parameters]
where command is:
  setup [-f] - setup the package directory
  create "package_name" - create new package
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
		setup|create)
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
