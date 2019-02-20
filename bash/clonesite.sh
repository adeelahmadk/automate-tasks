#!/usr/bin/env bash

# #######################################################
# Script: 	clonesite.sh                                #
# Version:	0.2                                         #
# Author:	Codegenki									#
# Date:		Feb 20, 2019                                #
# Usage:	scrape <uri>								#
# Description:	Bash script to clone an entire website	#
# #######################################################

print_usage() {
	echo "Usage: `basename $0` <uri>"
	echo "Try '`basename $0` --help' for more information."
}

print_help() {
	echo "Usage: `basename $0` <uri>"
	echo "Clone an entire website designated by <uri> avoiding out-of-domain links."
	echo
	echo "  <uri>       uri of the website, e.g. http://www.example.com"
	echo "Options"
	echo "  -h          Print this help"
}

if [ "$#" -eq 1 ] && [ "$1" = "--help" ]
then
	print_help
	exit 0
elif [ "$#" -eq 1 ]
then
    IN=$1
    arrIN=(${IN//\// })

    if [ ${#arrIN[@]} -gt 1 ]
    then
        uri=${arrIN[1]}
    elif [ ${#arrIN[@]} -eq 1 ]
    then
        uri=${arrIN[0]}
    fi

    url=(${uri//./ })
    domain="${url[1]}.${url[2]}"

    echo "Cloning ${domain} to ./${IN}:"
    echo

    wget \
         --recursive \
         --no-clobber \
         --page-requisites \
         --html-extension \
         --convert-links \
         --restrict-file-names=windows \
         --domains $domain \
         --no-parent \
         $IN

else
	print_usage
	exit 1
fi
