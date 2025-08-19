#!/usr/bin/env bash

#########################################################################################
# usage: mysql-setup-db-user.sh -d db -u db_user -p user_pass -a root_user -r root_pass
#########################################################################################

function usage() {
  echo "usage: `basename $0` -d db -u db_user -p user_pass -a root_user"
}

while getopts :d:u:p:a: option
do
  case "${option}"
  in
  d) DBNAME=${OPTARG};;
  u) DBUSER=${OPTARG};;
  p) DBPASS=${OPTARG};;
  a) ROOTUSER=${OPTARG};;
  \?) echo "Invalid Option: -$OPTARG";;
  :)  echo "Option -$OPTARG requires an argument.";;
  esac
done

[ -z "$ROOTUSER" ] && { echo "root user name required to execute operations" >&2; usage; exit 1; }

[ -z "$DBNAME" -o -z "$DBUSER" -o -z "$DBPASS" ] && { usage; exit 1; }

sudo -v
sudo mysql -u$ROOTUSER -e "CREATE DATABASE IF NOT EXISTS \`$DBNAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -u$ROOTUSER -e "CREATE USER '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASS';"
sudo mysql -u$ROOTUSER -e "GRANT ALL PRIVILEGES ON \`$DBNAME\`.* TO '$DBUSER'@'localhost';"
sudo mysql -u$ROOTUSER -e "FLUSH PRIVILEGES;"
