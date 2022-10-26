#!/bin/bash

# grep tag value = grep all files for tag:value
## Index functions
# edit key = get file on temp, vi it, and set

# init => initializes database
function database_init() {
	if [ ! -d "$DATABASE_DIR" ] ; then 
		mkdir -p "$DATABASE_DIR"
	fi

	if [ ! -f "$DATABASE_DIR/config.sh" ] ; then
		cat > "$DATABASE_DIR/config.sh" << __EOF__
DATABASE_KEY=md5
DATABASE_DIRWIDTH=3
DATABASE_DELIMITER=:
DATABASE_FILEEXT=md
__EOF__
	fi

	source "$DATABASE_DIR/config.sh"

	database_index_reload
}

# INTERNAL: database_index_reload => recriates the list os indexes
function database_index_reload() {
	DATABASE_INDEXES=()
	for index in "$DATABASE_DIR"/*.index ; do
		TAG=`basename "$index"`
		TAG=${TAG%.*}		
		DATABASE_INDEXES+=$TAG
	done
}

# INTERNAL: database_index_new tag => creates a new index based on tag
function database_index_new() {
	TAG="$1"

	if [ -z "$TAG" ] ; then return -1; fi

	touch "$DATABASE_DIR/$TAG.index"
	database_index_reload
	return 0
}

# INTERNAL: database_index_del tag => deletes an index on tag
function database_index_del() {
	TAG="$1"

	if [ -z "$TAG" ] ; then return -1; fi

	rm "$DATABASE_DIR/$TAG.index"
	database_index_reload
	return 0
}

# INTERNAL: filepath key => return file name by key
function database_filepath() {
	# echoes the path for the file in the database based on the key
	# uses as: vi `database_filepath "mykey"`
	if [ -z "$KEY" ] ; then return -1; fi
	KEY="$1" 

	if [ ${#KEY} -gt $DATABASE_DIRWIDTH ] ; then 
		PREFIX="${KEY:0:$DATABASE_DIRWIDTH}"
		echo "$DATABASE_DIR/$PREFIX/$KEY.$DATABASE_FILEEXT"
	fi
	return 0
}

# set key file = set file by key
function database_set() {
	# key file_to_save
	KEY="$1" 
	FILE="$2" 

	if [ -z "$KEY" ] ; then return -1; fi
	if [ -z "$FILE" ] ; then return -1; fi
	if [ ! -f "$FILE" ] ; then return -2; fi

	OUTFILE=`database_filepath "$KEY"`
	OUTDIR=`dirname "$OUTFILE"`

	mkdir -p "$OUTDIR"
	cp "$FILE" "$OUTFILE"

	return $?
}

# get key file => get file by key
function database_get() {
	KEY="$1" 
	OUTFILE="$2" 

	if [ -z "$KEY" ] ; then return -1; fi

	FILE=`database_filepath "$KEY"`
	if [ -z "$FILE" ] ; then return -1; fi

	OUTDIR=`dirname "$OUTFILE"`

	cp "$FILE" "$OUTFILE"

	return $?
}
# cat key file => cats file by key
function database_cat() {
	KEY="$1" 

	if [ -z "$KEY" ] ; then return -1; fi

	FILE=`database_filepath "$KEY"`

	cat "$FILE"

	return $?
}


# del key = remove file by key
function database_del() {
	# key
	KEY="$1"

	if [ -z "$KEY" ] ; then return -1; fi
	OUTFILE=`database_filepath "$KEY"`

	# file does not exist
	if [ ! -f "$FILE" ] ; then return 0; fi

	rm "$OUTFILE"
	RES=$?
	# remove directory if it is the last file
	OUTDIR=`dirname "$OUTFILE"`
	rmdir "$OUTDIR" >& /dev/null

	# remove on indexes
	for TAG in ${DATABASE_INDEXES[@]}; do
		database_index_update $TAG $KEY
	done

	return $RES
}

# INTERNAL: index_update tag key [value] => add index info for file under key. If value is ommited, the index entry is removed
function database_index_update() {
	TAG="$1"
	KEY="$2"
	VALUE="$3"

	if [ -z "$TAG" ] ; then return -1; fi
	if [ -z "$KEY" ] ; then return -1; fi
	INDEX="$DATABASE_DIR/$TAG.index"

	if [ -f "$INDEX" ] ; then
		# remove index entry
		cp "$INDEX" "$INDEX.tmp"
		#echo grep -v "^$KEY$DATABASE_DELIMITER" "$INDEX.tmp"
		grep -v "^$KEY$DATABASE_DELIMITER" "$INDEX.tmp" > "$INDEX"
		rm "$INDEX.tmp"
	fi

	# If value is ommited, the index entry is removed
	if [ -z "$VALUE" ] ; then return 0; fi

	echo "$KEY$DATABASE_DELIMITER$VALUE" >> "$INDEX"

	return 0
}

# index_lookup tag pattern = search index for tag, echoing every key that satisfies the pattern
function database_index_lookup() {
	TAG="$1"
	PATTERN="$2"

	if [ -z "$TAG" ] ; then return -1; fi
	if [ -z "$PATTERN" ] ; then return -1; fi

	INDEX="$DATABASE_DIR/$TAG.index"
	grep "^.*$DATABASE_DELIMITER.*$PATTERN.*$" "$INDEX" | cut -d $DATABASE_DELIMITER -f 1

	return 0
}

# INTERNAL: index_md_file => indexes an MD file
function database_index_md_file() {

	FILENAME="$1"
	if [ -z "$FILENAME" ] ; then return -1; fi

	KEY=`basename "$FILENAME"`
	KEY=${KEY%.*}

	database_index_reload

	source <(parse_yaml "$FILENAME" indexed_)

	echo Processing "$FILENAME" ...
	#echo "${!DATABASE_@}"
	#echo INDEXES: ${DATABASE_INDEXES[@]}
	#echo DATA: "${!indexed_@}"

	for TAG in ${DATABASE_INDEXES[@]}; do
		VALUE_VAR="indexed_$TAG"
		database_index_update $TAG $KEY "${!VALUE_VAR}"
	done

	unset "${!indexed_@}"
	return 0
}

# index tag = create an index for tag
function database_index() {
	find "$DATABASE_DIR"	-type f -name "*.$DATABASE_FILEEXT" -exec bash -c 'database_index_md_file "$0"' {} \;
	return 0
}

export -f database_index_md_file parse_yaml database_index_update database_index_reload
database_init
export "${!DATABASE_@}"
