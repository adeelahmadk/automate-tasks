#!/bin/bash
# full system restore
# #######################################################
# Script: 		      tar2part.sh                         #
# Version:		      0.1 							                  #
# Author:		        Adeel Ahmad (codegenki)		          #
# Date:			        Mar 27, 2019						            #
# Usage:		        tar2part <backupfile>               #
# Description: 	    Restore a mounted partition from    #
#                   a tarball                        	  #
# #######################################################
# Acknowledgement:  Based on Archwiki article: 'Full system backup with tar'
# https://wiki.archlinux.org/index.php/Full_system_backup_with_tar

print_usage() {
	echo "Usage: `basename $0` <backupfile>"
	echo "Try '`basename $0` --help' for more information."
}

print_help() {
	echo "Usage: `basename $0` <backupfile>"
	echo "restores a mounted partition from a tarball"
	echo
  echo "  <backupfile>        Name of the tarball (.tar.gz) file"
	echo "Options"
	echo "  -h, --help          Print this help"
}

if [ "$#" -ne 1 ]
	then
	print_usage
	exit 1
elif [ "$#" -eq 1 ] && [ "$1" = "--help" ] || [ "$1" = "-h" ]
	then
	print_help
	exit 0
else

  # Backup destination. Add this dir in Exclude file
  backdest="$1"

  # parse command line args for backup filename
  backupfile="$backdest"

  # Check if exclude file exists
  if [ ! -f $backupfile ]; then
    echo "Backup tarball doesn't exist!"
    print_usage
  	exit 1
  fi

  # Check if chrooted prompt.
  echo "First chroot from a LiveCD or bootable USB, set root(/) as pwd."
  echo "Mount required dirs (/,/home,/boot/efi) under chroot FS."
  echo -n "Are you ready to restore? (y/n): "
  read executerestore

  if [ $executerestore = "y" ]; then
    # -p and --xattrs store all permissions and extended attributes.
    # Without both of these, many programs will stop working!
    # It is safe to remove the verbose (-v) flag. If you are using a
    # slow terminal, this can greatly speed up the backup process.
    tar --xattrs -xpvf $backupfile
  fi
fi
