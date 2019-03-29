#!/bin/bash
# full system backup
# #######################################################
# Script:           part2tar                            #
# Version:          0.1                                 #
# Author:           Adeel Ahmad (codegenki)             #
# Date:             Mar 27, 2019                        #
# Usage:            part2tar <backupfile>               #
# Description:      Backup a mounted filesystem to      #
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
	echo "backup a mounted filesystem to a tarball"
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
  backdest="/mnt"

  # Labels for backup name
  host="think431"
  distro=`head -n 1 /etc/issue | awk '{for(i=1;i<NF-1;i++){printf "%s",$i;if(i<NF-2){printf "_"};};}'`
  date=`date "+%F"`
  backupfile="$backdest/$host-$distro-$date.tar.gz"

  # Exclude file location
  file=${0%.*}
  prog=${file##*/} # Program name from filename
  echo $prog
  # excdir="/home/adeel/.config/scripts/backup"
  excdir="/home/adeel/workspace/bash"
  exclude_file="$excdir/$prog-exc.txt"

  # Check if chrooted prompt.
  echo "First chroot from a LiveCD or bootable USB"
  echo "Mount required dirs (/,/home,/boot/efi) under chroot FS."
  echo -n "Are you ready to backup? (y/n): "
  read executeback

  # Check if exclude file exists
  if [ ! -f $exclude_file ]; then
    echo -n "No exclude file exists, continue? (y/n): "
    read continue
    if [ $continue == "n" ]; then exit; fi
  fi

  if [ $executeback = "y" ]; then
    # -p and --xattrs store all permissions and extended attributes.
    # Without both of these, many programs will stop working!
    # It is safe to remove the verbose (-v) flag. If you are using a
    # slow terminal, this can greatly speed up the backup process.
    tar --exclude-from=$exclude_file --xattrs -czpvf $backupfile /
  fi
fi
