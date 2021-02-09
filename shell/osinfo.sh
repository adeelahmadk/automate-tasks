#!/bin/bash

#########################################################
# Script:       osinfo.sh                               #
# Version:      0.2a                                    #
# Author:       Codegenki                               #
# Date:         Feb 20, 2019                            #
# Usage:        osinfo                                  #
# Description:  Bash script to list system information	#
#########################################################

SYSINFO=`head -n 1 /etc/issue | awk '{for(i=1;i<NF-1;i++){printf "%s ",$i}; printf "\n" }'`
# cat /etc/*-release | awk -F= '/DISTRIB_ID/{printf $2 " " }/VERSION=/{printf $2 "\n"}' | awk -F'"' '{print $1 $2}'
IFS=$'\n'
UPTIME=`uptime`
D_UP=${UPTIME:1}
MYGROUPS=`groups | awk '{for(i=1;i<=NF;i++){printf "%s ",$i; if(i%4==0){printf "\n\t\t"}}; printf "\n"}'`
DATE=`date`
KERNEL=`uname -srv`
CPWD=`pwd`
ME=`whoami`
CPU=`arch`

printf "<=== SYSTEM ===>\n"
echo "  Distro info:	"$SYSINFO""
printf "  Kernel:\t"$KERNEL"\n"
printf "  Uptime:\t"$D_UP"\n"
free -mt | awk '
/Mem/{print "  Memory:\tTotal: " $2 "Mb\tUsed: " $3 "Mb\tFree: " $4 "Mb"}
/Swap/{print "  Swap:\t\tTotal: " $2 "Mb\tUsed: " $3 "Mb\tFree: " $4 "Mb"}'
printf "  Architecture:\t"$CPU"\n"
cat /proc/cpuinfo | grep "model name\|processor" | awk '
/processor/{printf "  Processor:\t" $3 " : " }
/model\ name/{
i=4
while(i<=NF){
	printf $i
	if(i<NF){
		printf " "
	}
	i++
}
printf "\n"
}'
printf "  Date:\t\t"$DATE"\n"

printf "\n<=== USER ===>\n"
printf "  User:\t\t"$ME" (uid:"$UID")\n"
printf "  Groups:\t"
echo "$MYGROUPS"
#printf "\n"
# printf "  Working dir:\t"$CPWD"\n"
printf "  Home dir:\t"$HOME"\n"

printf "\n<=== NETWORK ===>\n"
printf "  Hostname:\t"$HOSTNAME"\n"
ip -o addr | awk '/inet /{print "  IP (" $2 "):\t" $4}'
/sbin/route -n | awk '/^0.0.0.0/{ printf "  Gateway:\t"$2"\n" }'
cat /etc/resolv.conf | awk '/^nameserver/{ printf "  Name Server:\t" $2 "\n"}'
