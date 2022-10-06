#!/usr/bin/env sh

# #####################################################
# Script:       parser.sh                             #
# Version:      0.30                                  #
# Author:       Adeel Ahmad (adeelahmadk)             #
# Date Crated:  Sep 26, 2022 (rewrite)                #
# Date Updated: Sep 27, 2022                          #
# Usage:        parser n                              #
# Description:  Feed parser script to read,format and #
#               print feeds, cached by the reader     #
#               from a default directory.             #
# #####################################################

# Executables with absolute paths
_awk=`which awk`
_sed=`which sed`

# Global Vars
_DEFAULT_STORE="$HOME/.cache/rss-reader"
NUM_ROWS=0

print_usage() {
    echo "Usage: `basename $0` n" 1>&2
    echo "Read feed headlines from files (named domain.feed) in the default store" 1>&2
    echo "  n   number of feed headlines / file" 1>&2
}

is_integer ()
{
    case "${1#[+-]}" in
        (*[!0123456789]*) return 1 ;;
        ('')              return 1 ;;
        (*)               return 0 ;;
    esac
}

if [ "$#" -eq 0 ]; then
    print_usage
    return 1
elif [ "$#" -eq 1 ]; then
    if [ "$1" = "-h" ]; then
        print_usage
        return 0
    fi
    if ! is_integer "$1" ; then
        echo "n is not an integer"
        print_usage
        exit 2
    fi

    NUM_ROWS="$1"
    if [ ! -d "$_DEFAULT_STORE" ]; then
        echo "feed store ${_DEFAULT_STORE} not found" 1>&2
        return 4
    fi

    # trim lines after max length
    MAX_LEN=75
    # read feeds
    NUM_ROWS=$(($NUM_ROWS + 1))     # add 1 for the heading
    for FILE in $_DEFAULT_STORE/*; do
        #echo "reading "$FILE" now..."
        $_awk -v n=$NUM_ROWS \
            'BEGIN{ RS="\n\n"; ORS="" }
            NR==2 {print "\n"}
            {print $0 "\n"}
            NR==n {exit}' \
            $FILE \
        | $_sed 's/\(^.\{'"$MAX_LEN"'\}\).*/\1.../' # trunc at max length
        printf "\n"
    done
fi
