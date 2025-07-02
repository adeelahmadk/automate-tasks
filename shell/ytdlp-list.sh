#!/usr/bin/env bash

#################################################################
# Script:       net-test.sh                                     #
# Version:      0.1.1                                           #
# Author:       Adeel Ahmad (codegenki)                         #
# Date Created: Jun 20, 2021                                    #
# Date Mod.:    Jul 10, 2021                                    #
# Usage:        ytdl-list <playlist-url> [DIR]                  #
# Description:  Bash script to download a youtube playlist      #
# Example:      ./ytdl-list.sh                                  #
#                   https://www.youtube.com/playlist?list=XYZ   #
#                   $HOME/Videos/                               #
#################################################################

print_usage() {
    echo "Usage:`basename $0` URL [PATH] [LISTITEMS]" 1>&2
    echo "Download a playlist from youtube." 1>&2
    echo
    echo "  URL         link to the playlist." 1>&2
    echo "  PATH        path to save the list." 1>&2
    echo "  LISTITEMS   playlist items to download (e.g. 3-7)." 1>&2
}

# at least a url is required.
if [ "$#" -lt 1 ]; then print_usage; exit 1; fi

URL="$1"
DEST=
LIST_OPT=

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

if [ "$#" -gt 2 ] && [ -n "$3" ]; then
    LIST_OPT="--playlist-items $3"
else
    LIST_OPT="--yes-playlist"
fi

echo "Destination: ${DEST}"
echo "List Option: ${LIST_OPT}"

# download the video in 720p quality
yt-dlp -f22  "${LIST_OPT}" -o "${DEST}/%(playlist_title)s-%(playlist_index)s-%(title)s_%(resolution)s.%(ext)s" "${URL}"

