#!/bin/bash

# ####################################################
# Script:       img_orient.sh                        #
# Version:      0.3.0                                #
# Author:       Adeel Ahmad (adeelahmadk)            #
# Date Crated:  Apr 07, 2026                         #
# Date Updated: Apr 08, 2026                         #
# Usage:        image_orient.sh [DIR]                #
# Description:  Auto correct orientation of photos   #
#               in portrait mode (single dependency).#
# Dependencies: - imagemagick                        #
# ####################################################

# Directory to search (defaults to current directory) and target directory
SEARCH_DIR="${1:-.}"
DEST_DIR="$SEARCH_DIR/rotated"

# Check for required tools
if ! command -v convert &>/dev/null; then
  echo "Error: 'ImageMagick' must be installed."
  exit 1
fi

# Create the destination directory
mkdir -p "$DEST_DIR" 2>/dev/null || {
  echo "unable to create $DEST_DIR"
  exit 1
}

echo "Finding images with portrait orientation in: $SEARCH_DIR"
echo "Saving corrected images to: $DEST_DIR/"

# 1. Use 'identify' to find files with orientation 8
for file in *; do
  if [ $(identify -format "%[exif:orientation]" "$file") -eq 8 ]; then
    echo "$file"
  fi
done | while read -r file; do
  filename=$(basename "$file")
  echo "Processing: $filename"
  # 2. Use 'convert' to rotate them and save to the destination folder
  convert "$file" -auto-orient "$DEST_DIR/$filename"
done

echo "Done processing!"
echo "Check the '$DEST_DIR' folder for your rotated images."
