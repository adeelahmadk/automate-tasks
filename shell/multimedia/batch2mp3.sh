#!/usr/bin/env bash

DEST="./mp3"
mkdir -p "$DEST"

for f in *.m4a; do
  ffmpeg -i "${f}" \
    -map_metadata 0 \
    -c:a libmp3lame \
    -q:a 2 \
    "$DEST/${f%.m4a}.mp3"
done
