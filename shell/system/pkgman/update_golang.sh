#!/bin/bash

#########################################################
# Script:       update_golang                           #
# Version:      0.1                                     #
# Author:       Adeel Ahmad (adeelahmadk)               #
# Date Created: Jan 3, 2026                             #
# Date Mod.:    Jan 3, 2026                             #
# Usage:        update_golang                           #
# Description:  Script to install/update golang         #
#########################################################

set -e

sudo -v

GOLANG_DL_STR=$(curl -s -L "https://go.dev/dl" | grep 'downloadBox.*linux' | awk '{print $4}' | awk -F= '{gsub(/[">]/, "", $2);}{print $2}')
GOLANG_VER=$(echo $GOLANG_DL_STR | awk -F- '{print $1}' | awk -F/ '{print $3}')
GOLANG_VER=${GOLANG_VER%.*}
GOLANG_PKG="https://go.dev"$GOLANG_DL_STR
DLFILE="$HOME/Downloads/golang.tar.gz"

decision="y"

if command -v "go" > /dev/null; then
  printf "Golang:\n  Installed: %s\n  Latest: %s\n" "$(go version | awk '{print $3}')" "$GOLANG_VER" 
  read -p "Continue install (y/n)?" -n1 -r choice
  case "$choice" in 
    y|Y ) decision="y";;
    n|N ) decision="n";;
    * )   decision="n";;
  esac

  sudo -v

  [ "$decision" = "y" ] && { 
    echo "Upgrading..."
    sudo bash -c "rm -rf /usr/local/go"
  }
else
  printf "Golang not installed, " 
  read -p "continue install ${GOLANG_VER} (y/n)?" -n1 -r choice
  case "$choice" in 
    y|Y ) decision="y";;
    n|N ) decision="n";;
    * )   decision="n";;
  esac
  [ "$decision" = "y" ] && echo "Installing..."
fi

sudo -v

[ "$decision" = "y" ] && {
  curl -fsSL "$GOLANG_PKG" -o "$DLFILE" && \
  sudo bash -c "tar -C /usr/local -xzf $DLFILE" && \
  rm "$DLFILE"
  echo "${GOLANG_VER} installation complete!"
  exit 0
} || {
  echo
  echo "skipping installation!"
}

