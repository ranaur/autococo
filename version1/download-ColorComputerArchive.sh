#!/bin/bash
# Downloads the files from Color Computer archive and stores in archive folder

source `dirname "$0"`/config.sh

if [[ -z "$1" ]] ; then
	cat << __EOF__
usage: `basename $0` <Repository Dir>

	Downloads from repository of https://colorcomputerarchive.com/repo/<Repository Dir>
__EOF__
	exit 0
fi

pushd "$ARCHIVE_DIR" > /dev/null
wget -r -l0 -np -nc https://colorcomputerarchive.com/repo/$1/
RES=$?
find colorcomputerarchive.com -name index.html\* -print -exec rm {} \;
popd > /dev/null

exit $RES
