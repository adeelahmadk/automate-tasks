#!/usr/bin/env bash

#
# manually uninstall python installed from source
# Author: Adeel Ahmad
# SPDX-License-Identifier: MIT
#

PREFIX="$HOME/.local"
VERSION="3.14"

print_usage() {
  echo "Usage: $(basename $0) [[-p PATH] [-v Version] | [-h | --help]]"
  echo
  echo "Options"
  echo "  -p PATH     Installation prefix, default: ~/.local"
  echo "  -v version  Version number, default: 3.14"
  echo "  -h, --help  Print this help"
}

if [ "$#" -eq 1 ] && [ "$1" = "--help" ]; then
  print_usage
  exit 0
fi

path=
ver=
# Cycle through all the options
while getopts 'p:v:h' argv; do
  case $argv in
  p) path=$OPTARG ;;
  v) ver=$OPTARG ;;
  h) print_usage && exit 0 ;;
  \?) echo "Invalid option: -$OPTARG" >&2 && exit 1 ;;
  esac
done

# Shift through option list
shift $((OPTIND - 1))
if [ "$#" -gt 0 ]; then
  print_usage
  exit 1
fi

PREFIX="${path:-$PREFIX}"
VERSION="${ver:-$VERSION}"

# check if prefix dir exists
[ -d "$PREFIX" ] &&
  { printf "removing Python-${VERSION} from ${PREFIX}\n\n"; } ||
  {
    echo "Not a valid path: ${PREFIX}"
    exit 1
  }

# check if python binary exists in prefix dir
[ ! -f "$PREFIX"/bin/python"$VERSION" ] && {
  printf "Python-${VERSION} not installed in ${PREFIX}\n"
  exit 1
}

# clean bin/
rm "$PREFIX"/bin/python"$VERSION"*
rm "$PREFIX"/bin/pydoc"$VERSION"
rm "$PREFIX"/bin/pip"$VERSION"

# clean lib/
rm "$PREFIX"/lib/libpython"$VERSION"*
rm -rf "$PREFIX"/lib/python"$VERSION"
rm "$PREFIX"/lib/pkgconfig/python-"$VERSION"*

# clean include/
rm -rf "$PREFIX"/include/python"$VERSION"

# clean man page
rm "$PREFIX"/share/man/man1/python"$VERSION"*
