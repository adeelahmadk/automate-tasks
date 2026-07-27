#!/bin/bash

# ####################################################
# Script:       img_orient_progress.sh               #
# Version:      0.2                                  #
# Author:       Adeel Ahmad (adeelahmadk)            #
# Date Crated:  Apr 08, 2026                         #
# Date Updated: Apr 08, 2026                         #
# Usage:        img_orient_progress.sh [DIR]         #
# Description:  Auto correct orientation of photos   #
#               taken in portrait mode efficiently.  #
#               with a progress bar.                 #
# Dependencies: - exiftool                           #
#               - imagemagick                        #
#               - dialog                             #
# ####################################################

# Directory to search (defaults to current directory) and target directory
SEARCH_DIR="${1:-.}"
DEST_DIR="$SEARCH_DIR/fixed"

# Check for required tools
if ! command -v exiftool &>/dev/null ||
  ! command -v convert &>/dev/null ||
  ! command -v dialog &>/dev/null; then
  echo "Error: Dependencies must be installed."
  echo -e "  - 'exiftool'\n  - 'imagemagick'\n  - 'dialog'"
  exit 1
fi

# Create the target directory if it doesn't exist
mkdir -p "$DEST_DIR" 2>/dev/null || {
  echo "unable to create $DEST_DIR"
  exit 1
}

echo "Finding images with portrait orientation in: $SEARCH_DIR"
echo "Saving corrected versions to: $DEST_DIR/"

files=()

# Use < <() instead of | to avoid the subshell issue
while read -r file; do
  echo "Found: $file"
  files+=("$file")
done < <(exiftool -if '$Orientation# == 8' -p '$Directory/$FileName' -r "$SEARCH_DIR")

total=${#files[@]}
current=0

for file in "${files[@]}"; do
  current=$((current + 1))
  percent=$((current * 100 / total))

  # Get just the filename
  filename=$(basename "$file")

  # Send updates to dialog
  echo "XXX"
  echo "Processing $filename ($current of $total)"
  echo "XXX"
  echo "$percent"

  # -auto-orient rotates the pixels AND resets the orientation tag to 1
  convert "$file" -auto-orient "$DEST_DIR/$filename"
done | dialog --title "Auto Orient Images" --gauge "Starting..." 7 75 0

clear
echo "Processing complete!"
echo "Check the '$DEST_DIR' folder for your rotated images."
