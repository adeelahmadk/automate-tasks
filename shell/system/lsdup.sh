#!/usr/bin/env bash

##########################################################
# Script:       lsdup.sh                                 #
# Version:      0.1.0                                    #
# Author:       Adeel Ahmad (adeelahmadk)                #
# Date Created: Aug 16, 2026                             #
# Date Mod.:    Aug 17, 2026                             #
# Usage:        lsdup.sh DIR1 DIR2                       #
# Description:  list duplicate files in DIR1 w.r.t. DIR2 #
##########################################################

usage() {
  echo "Usage: $(basename $0) dir1 dir2"
  echo "Find duplicate files in two directories and list duplicates from the first one"
  echo
  return 1
}

[ "$#" -ne 2 ] && {
  usage
  exit 1
}

[ ! -d "$1" -o ! -d "$2" ] && {
  usage
  exit 1
}

find "$1" "$2" ! -empty -type f -exec md5sum {} \; |
  sort -rn |
  uniq -w32 -dD |
  rg "$1" |
  cut -d' ' -f2- |
  sed -e 's/^[ \t]*/"/g' -e 's/[ \t]*$/"/g'
