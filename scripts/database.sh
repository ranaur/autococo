#!/usr/bin/env bash

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
	local index
	DATABASE_INDEXES=()
	for index in "$DATABASE_DIR"/*.index ; do
		local tag=`basename "$index"`
		tag=${tag%.*}		
		DATABASE_INDEXES+=$tag
	done
}

# INTERNAL: database_index_new tag => creates a new index based on tag
function database_index_new() {
	local tag="$1"

	if [ -z "$tag" ] ; then return -1; fi

	touch "$DATABASE_DIR/$tag.index"
	database_index_reload
	return 0
}

# INTERNAL: database_index_del tag => deletes an index on tag
function database_index_del() {
	local tag="$1"

	if [ -z "$tag" ] ; then return -1; fi

	rm "$DATABASE_DIR/$tag.index"
	database_index_reload
	return 0
}

# INTERNAL: filepath key => return file name by key
function database_filepath() {
	# echoes the path for the file in the database based on the key
	# uses as: vi `database_filepath "mykey"`
	local key="$1" 
	if [ -z "$key" ] ; then return -1; fi

	if [ ${#key} -gt $DATABASE_DIRWIDTH ] ; then 
		local prefix
		prefix="${key:0:$DATABASE_DIRWIDTH}"
		echo "$DATABASE_DIR/$prefix/$key.$DATABASE_FILEEXT"
	else
		echo "$DATABASE_DIR/$key.$DATABASE_FILEEXT"
	fi
	return 0
}

# set key file = set file by key
function database_set() {
	# key file_to_save
	local key="$1" 
	local file="$2" 

	if [ -z "$key" ] ; then return -1; fi
	if [ -z "$file" ] ; then return -1; fi
	if [ ! -f "$file" ] ; then return -2; fi

	outfile=`database_filepath "$key"`
	outdir=`dirname "$outfile"`

	mkdir -p "$outdir"

	cp "$file" "$outfile"

	return $?
}

# get key file => get file by key
function database_get() {
	local key="$1" 
	local outfile="$2" 

	if [ -z "$key" ] ; then return -1; fi

	FILE=`database_filepath "$key"`
	if [ -z "$file" ] ; then return -1; fi

	local outdir=`dirname "$outfile"`

	cp "$file" "$outfile"

	return $?
}
# cat key file => cats file by key
function database_cat() {
	local key="$1" 

	if [ -z "$key" ] ; then return -1; fi

	FILE=`database_filepath "$key"`

	cat "$file"

	return $?
}


# del key = remove file by key
function database_del() { # key
	local key="$1"

	if [ -z "$key" ] ; then return -1; fi
	local outfile=`database_filepath "$key"`

	# file does not exist
	if [ ! -f "$outfile" ] ; then return 0; fi

	rm "$outfile"
	local res=$?

	# remove directory if it is the last file
	local outdir=`dirname "$outfile"`
	rmdir "$outdir" >& /dev/null

	# remove on indexes
	local tag
	for tag in ${DATABASE_INDEXES[@]}; do
		database_index_update $tag $key
	done

	return $res
}

# INTERNAL: index_update tag key [value] => add index info for file under key. If value is ommited, the index entry is removed
function database_index_update() {
	local tag="$1"
	local key="$2"
	local value="$3"

	if [ -z "$tag" ] ; then return -1; fi
	if [ -z "$key" ] ; then return -1; fi
	local index="$DATABASE_DIR/$tag.index"

	if [ -f "$index" ] ; then
		# remove index entry
		cp "$index" "$index.tmp"
		#echo grep -v "^$key$DATABASE_DELIMITER" "$index.tmp"
		grep -v "^$key$DATABASE_DELIMITER" "$index.tmp" > "$index"
		rm "$index.tmp"
	fi

	# If value is ommited, the index entry is removed
	if [ -z "$value" ] ; then return 0; fi

	echo "$key$DATABASE_DELIMITER$value" >> "$index"

	return 0
}

# index_lookup tag pattern = search index for tag, echoing every key that satisfies the pattern
function database_index_lookup() {
	local tag="$1"
	local pattern="$2"

	if [ -z "$tag" ] ; then return -1; fi
	if [ -z "$pattern" ] ; then return -1; fi

	local index="$DATABASE_DIR/$tag.index"
	grep "^.*$DATABASE_DELIMITER.*$pattern.*$" "$index" | cut -d $DATABASE_DELIMITER -f 1

	return 0
}

# INTERNAL: index_md_file => indexes an MD file
function database_index_md_file() {
	local filename="$1"
	if [ -z "$filename" ] ; then return -1; fi

	local key=`basename "$filename"`
	key=${key%.*}

	database_index_reload

	source <(parse_yaml "$filename" indexed_)

	echo Processing "$filename" ...
	#echo "${!DATABASE_@}"
	#echo INDEXES: ${DATABASE_INDEXES[@]}
	#echo DATA: "${!indexed_@}"

	local tag
	for tag in ${DATABASE_INDEXES[@]}; do
		local value_var="indexed_$tag"
		database_index_update $tag $key "${!value_var}"
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
