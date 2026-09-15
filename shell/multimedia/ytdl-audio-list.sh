#!/usr/bin/env bash

usage() {
  echo "usage: $(basename $0) FILE"
  echo "  FILE  A list of Youtube video URLs."
  exit 1
}

[ "$#" -lt 1 -o "$#" -gt 2 ] && {
  usage
}

FMT="136+140-drc"
FMT_BAK="136+140"
FMT_USR=
while getopts ":f:" opt; do
  case ${opt} in
  f)
    FMT_USR="$OPTARG"
    ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    usage
    ;;
  :)
    echo "Option -$OPTARG requires an argument." >&2
    usage
    ;;
  esac
done

shift $((OPTIND - 1))

[ ! -f "$1" ] && {
  usage
}

pull_url() {
  if [[ -n "$FMT_USR" ]]; then
    yt-dlp -f "$FMT_USR" "$1"
  else
    yt-dlp -f "$FMT" "$1"

    [ "$?" -ne 0 ] && yt-dlp -f "$FMT_BAK" "$1"
  fi
  return "$?"
}

_FILE="$1"
while IFS= read -r url; do
  URL=$(echo "$url" | cut -d'?' -f1)
  echo ">>> Processing: $URL"

  pull_url "$URL"

  if [[ "$?" == 0 ]]; then
  	print "\n=== done ===\n"
  else
  	print "\n=== failed ===\n"
  fi
  print "--------------------------------------------------------\n\n"

  sleep 3
done <"$_FILE"
