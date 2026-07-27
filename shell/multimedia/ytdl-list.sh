#!/usr/bin/env bash

#################################################################
# Script:       ytdl-list.sh                                    #
# Version:      0.1.2                                           #
# Author:       Adeel Ahmad (adeelahmadk)                       #
# Date Created: Jun 20, 2021                                    #
# Date Mod.:    Dec 15, 2025                                    #
# Usage:        ytdl-list <playlist-url> [DIR]                  #
# Description:  Bash script to download a youtube playlist      #
# Example:      ./ytdl-list.sh                                  #
#                   https://www.youtube.com/playlist?list=XYZ   #
#                   $HOME/Videos/                               #
#################################################################

print_usage() {
    echo "Usage:`basename $0` URL [PATH]" 1>&2
    echo "Download a playlist from youtube." 1>&2
    echo
    echo "  URL     link to the playlist." 1>&2
    echo "  PATH    path to save the list." 1>&2
}

# at least a url is required.
if [ "$#" -lt 1 ]; then print_usage; exit 1; fi

URL="$1"
DEST=

# check for the destination dir
if [ "$#" -ge 2 ] && [ -d "$2" ]; then
    DEST="$2"
else
    # generate a unique suffix for the
    # directory name as Year-Month-Date_Nanosec
    CRON_SUFFIX=$(date +'%Y-%m-%d_%s%N')
    # create a uniquely named dir in ~/Videos
    DEST="${HOME}/Videos/playlist_${CRON_SUFFIX}"
    mkdir -p "${DEST}"
fi

# download the video in 720p quality
youtube-dl -f22 --yes-playlist -o "${DEST}/%(playlist_title)s-%(playlist_index)s-%(title)s[%(resolution)s].%(ext)s" "${URL}"

