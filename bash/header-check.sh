#!/bin/bash

#########################################################
# Script:       net-test.sh	                            #
# Version:      0.1                                     #
# Author:       Adeel Ahmad (codegenki)                 #
# Date:         May 16, 2019                            #
# Usage:        header-check <url-file>                 #
# Description:  Bash script to run bulk HTTP header     #
#               status check.                           #
#########################################################

print_usage() {
	echo "Usage: `basename $0` <url-file>"      # default: urlfile.txt
	echo "Try '`basename $0` --help' for more information."
}

print_help() {
	echo "Usage: `basename $0` <url-file>"
	echo "Bulk HTTP header status check."
	echo
	echo "  <url-file>  A file containing a list of urls (1 per line)"
	echo "Options"
	echo "  -h          Print this help"
}

if [ "$#" -ne 1 ]
then
	print_usage
	exit 1
elif [ "$#" -eq 1 ] && [ "$1" = "--help" ]
then
	print_help
	exit 0
else
    #echo "# Simple Massive HTTP Header Status Checker";

    file=$1
    while IFS= read bulk
    do
      curl -o /dev/null --max-time 10 --silent --head --write-out "%{http_code} - $bulk\n" "$bulk"
    done < "$file"

    exit 0
fi
