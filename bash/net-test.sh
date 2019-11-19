#! /usr/bin/env bash

#########################################################
# Script: 		net-test.sh						       	#
# Version:		0.2 							     	#
# Author:		Adeel Ahmad (codegenki)			       	#
# Date:			May 16, 2019					     	#
# Usage:		net-test <url-file>                    	#
# Description: 	Bash script to check internet connection#
#########################################################

print_usage() {
	echo "Usage: `basename $0` [OPTION] [FILE]" >& 2      # default: urlfile.txt
	echo "Try '`basename $0` --help' for more information."  >& 2
}

print_help() {
	echo "Usage: `basename $0` [OPTION] [FILE]"  >& 2
	echo "Check your internet connectivty."  >& 2
	echo  >& 2
	echo "Options"  >& 2
	echo "  -a          Auto test, with default file"  >& 2
	echo "  -f FILE     Test with the given file containing a list of urls" >& 2
	echo "              (1 per line)"  >& 2
	echo "  -h          Print this help"  >& 2
}

if [ "$#" -lt 1 ]
then
	print_usage
	exit 1
elif [ "$#" -eq 1 ] && [ "$1" = "--help" ]
then
	print_help
	exit 2
else
    optspec=":afh:"
  # Cycle through all the options
	while getopts "$optspec" argv
	do
		case "${argv}" in
		    -)
		        case "${OPTARG}" in
		            help)
			            print_help && exit 0
			            ;;
		            *)
		                if [ "$OPTERR" = 1 ] && [ "${argv:0:1}" != ":" ]
		                then
		                    echo "Found unknown option --${OPTARG}" >& 2
		                fi
		                ;;
		        esac;;
			a)
			    auto=1; file="./urlfile.txt"
			    ;;
			f)
			    val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
			    file="${val}"
			    ;;
			h)
			    print_help && exit 2
			    ;;
			*)
                if [ "$OPTERR" = 1 ] && [ "${argv:0:1}" != ":" ]
                then
                    echo "Found unknown option -${OPTARG}" >& 2
                fi
                echo >& 2
			    print_usage && exit 1
			    ;;
		esac
	done

	if [[ -f $file ]]
	then
        echo "Checking your internet connectivity status...";

	    RED=$(tput setaf 1)
	    GREEN=$(tput setaf 2)
    	YELLOW=$(tput setaf 3)
     	NC=$(tput sgr0) 
    	online="${GREEN}reachable$NC" offline="${RED}unreachable$NC"

        success=0
        links=0
        while IFS= read uri
        do
            status=`curl -o /dev/null --max-time 10 --silent --head --write-out "%{http_code}" "$uri"`
            links=$(expr $links + 1)
            if [[ "$status" == "200" ]]   # check for code 3xx [[ $status -ge 300 ]] && [[ "$status" -lt 400 ]] 
            then
                state=$online
                success=$(expr $success + 1)
	        else
	            state=$offline
            fi
            #echo $status
	        printf 'Host %-15s: %s\n' "$uri" "$state"
        done < "$file"

        favorable=`printf %.0f $(echo "scale=2;($success/$links)*100" | bc -q)`
    	echo

        if [[ $success -ge 1 ]]
        then
            echo "You are connected to the internet!"
            if [[ $favorable -le 50 ]]
            then
                echo "Success: $favorable%. You are behind a firewall!"
            fi
        else
            echo "Something wrong with the internet!"
        fi

        exit 0
    else
        echo "$file does not exist!" >& 2
        exit 1
    fi
fi

