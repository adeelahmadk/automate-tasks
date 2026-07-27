#!/bin/bash

# ####################################################
# Script:       img_orientx.sh                       #
# Version:      0.2                                  #
# Author:       Adeel Ahmad (adeelahmadk)            #
# Date Crated:  Apr 08, 2026                         #
# Date Updated: Apr 08, 2026                         #
# Usage:        image_orientx.sh [DIR]               #
# Description:  Auto correct orientation of photos   #
#               taken in portrait mode efficiently.  #
# Dependencies: - exiftool                           #
#               - imagemagick                        #
# ####################################################

# Directory to search (defaults to current directory)
SEARCH_DIR="${1:-.}"
DEST_DIR="$SEARCH_DIR/rotated"

# Check for required tools
if ! command -v exiftool &>/dev/null || ! command -v convert &>/dev/null; then
  echo "Error: Both 'exiftool' and 'imagemagick' must be installed."
  exit 1
fi

# Create the target dir if it doesn't exist
mkdir -p "$DEST_DIR" 2>/dev/null || {
  echo "unable to create $DEST_DIR"
  exit 1
}

echo "Finding images with Orientation 8 in: $SEARCH_DIR"
echo "Saving corrected versions to: $TARGET_DIR/"

# 1. Use ExifTool to find files with orientation 8
exiftool -if '$Orientation# == 8' -p '$Directory/$FileName' -r "$SEARCH_DIR" | while read -r file; do
  # Get the filename
  filename=$(basename "$file")
  echo "Processing: $filename"

  # 2. Use 'convert' to auto orient image and save to the new folder
  convert "$file" -auto-orient "$TARGET_DIR/$filename"
done

echo "Done! Check the '$TARGET_DIR' folder for your rotated images."
