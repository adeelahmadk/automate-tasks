#!/usr/bin/env bash

################################################################
# usage: mysql-drop-all-tables -d database -u dbuser -p dbpass
################################################################

function usage() {
	echo "usage: `basename $0` -d database -u dbuser -p dbpass"	
}

# prefix for the temp dir & files
PREFIX=$(basename "$0" | awk 'BEGIN{FS=OFS="."} {NF--; print}')

#TEMP_FILE_PATH='./drop_all_tables.sql'
TEMP_FILE_PATH="$(mktemp $PREFIX.XXXXXXXXXX)" || \
          { echo "Failed to create temp file"; exit 1; }

while getopts d:u:p: option
do
	case "${option}"
	in
	d) DBNAME=${OPTARG};;
	u) DBUSER=${OPTARG};;
	p) DBPASS=${OPTARG};;
	esac
done

echo "SET FOREIGN_KEY_CHECKS = 0;" > $TEMP_FILE_PATH
( mysqldump --add-drop-table --no-data -u$DBUSER -p$DBPASS $DBNAME | grep 'DROP TABLE' ) >> $TEMP_FILE_PATH
echo "SET FOREIGN_KEY_CHECKS = 1;" >> $TEMP_FILE_PATH
mysql -u$DBUSER -p$DBPASS $DBNAME < $TEMP_FILE_PATH
rm -f $TEMP_FILE_PATH

# clean up (trap EXIT signal)
trap '{ rm -f -- $TEMP_FILE_PATH; }' EXIT
