#!/usr/bin/env bash

# #######################################################
# Script:       clonesite.sh                            #
# Version:      0.2a                                    #
# Author:       Codegenki                               #
# Date:         Feb 20, 2019                            #
# Usage:        scrape <uri>                            #
# Description:  Bash script to clone an entire website  #
# #######################################################

PROGNAME=`basename $0`

print_usage() {
	echo "Usage: $PROGNAME <uri>
Try '$PROGNAME --help' for more information.
    "
    return
}

print_help() {
	echo "Usage: $PROGNAME <uri>
Clone an entire website designated by <uri> avoiding out-of-domain links.

  <uri>   uri of the website, e.g. http://www.example.com
  Options
    -h    Print this help"
}

if [ "$#" -eq 1 ] && [ "$1" = "--help" ]
then
	print_help
	exit
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
	print_usage >&2
	exit 1
fi
