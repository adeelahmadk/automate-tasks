#! /usr/bin/env sh

#########################################################
# Script:       net-test.sh                             #
# Version:      0.2.0                                   #
# Author:       Adeel Ahmad (adeelahmadk)               #
# Date Created: May 16, 2019                            #
# Date Mod.:    June 3, 2022                            #
# Usage:        net-test [OPTION] [FILE]                #
# Description:  Bash script to check internet connection#
#########################################################

PROGNAME=`basename $0`

print_usage() {
    # default: urlfile.txt
    echo "Usage: $PROGNAME [OPTION] [FILE]

Try '$PROGNAME --help' for more information."
    return
}

print_help() {
  echo "Usage: $PROGNAME [OPTION] [FILE]
Check your internet connectivty.

  Options
    -a          Auto test, with default file
    -f FILE     Test with the given file containing a list of urls
                (1 per line)
    -h          Print this help"
    return
}

error() {
  echo -e "\\e[91m$1\\e[39m"
  exit 1
}

msg() {
    echo "\\e[1;32m$1\\e[0m"
}

check_connectivity() {
  printf "Checking if you are online..."
  wget -q --spider http://github.com
  if [ $? -eq 0 ]; then
    msg "Online. Continuing."
  else
    error "Offline! Connect to the internet then run the script again."
  fi
  return
}

if [ "$#" -lt 1 ]; then
  print_usage
  exit 1
elif [ "$#" -eq 1 ] && [ "$1" = "--help" ]; then
  print_help
  exit
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
        auto=1; file="$(dirname $0)/urlfile.txt"
        ;;
      f)
        val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
        file="${val}"
        ;;
      h)
        print_help
        exit
        ;;
      *)
        if [ "$OPTERR" = 1 ] && [ "${argv:0:1}" != ":" ]; then
          echo "Found unknown option -${OPTARG}" >& 2
        fi
        print_usage >&2
        exit 1
        ;;
    esac
  done

  check_connectivity
  
  if [ -f $file ]; then
    echo "Checking your internet connectivity status...";

    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    NC=$(tput sgr0)
    online="${GREEN}reachable${NC}"
    offline="${RED}unreachable${NC}"

    success=0
    links=0
    while IFS= read uri
    do
      status=`curl -o /dev/null --max-time 10 --silent --head --write-out "%{http_code}" "$uri"`
      links=$(($links + 1))
      if [ "$status" = "200" ]   # check for code 3xx [[ $status -ge 300 ]] && [[ "$status" -lt 400 ]]
      then
        state="$online"
        success=$(($success + 1))
      else
        state="$offline"
      fi
      #echo $status
      printf '  %-22s : %-s\n' "$state" "$uri"
    done < "$file"

    success_rate=`printf %.0f $(echo "scale=2;($success/$links)*100" | bc -q)`
    echo

    if [ $success -ge 1 ]
    then
        msg "You are connected & most of the internet is reachable!"
        if [ $success_rate -le 50 ]
        then
            echo "Success: $success_rate%. You are probably behind a firewall!"
        fi
    else
        echo "Something wrong with the internet!"
    fi

    exit 0
  else
      error "$file does not exist!" >&2
  fi
fi

