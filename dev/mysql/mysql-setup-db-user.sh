#!/usr/bin/env bash

#########################################################################################
# usage: mysql-setup-db-user.sh -d db -u db_user -p user_pass -a root_user -r root_pass
#########################################################################################

function usage() {
	echo "usage: `basename $0` -d db -u db_user -p user_pass -a root_user -r root_pass"
}

ROOTPASS=

while getopts :d:u:p:a:r: option
do
	case "${option}"
	in
	d) DBNAME=${OPTARG};;
	u) DBUSER=${OPTARG};;
	p) DBPASS=${OPTARG};;
	a) ROOTUSER=${OPTARG};;
	r) ROOTPASS=${OPTARG};;
	\?) echo "Invalid Option: -$OPTARG";;
	:)  echo "Option -$OPTARG requires an argument.";;
	esac
done

[ -z "$ROOTUSER" ] && { echo "root user name required to execute operations" >&2; usage; exit 1; }

[ -z "$DBNAME" -o -z "$DBUSER" -o -z "$DBPASS" ] && { usage; exit 1; }

mysql -u$ROOTUSER -p$ROOTPASS -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u$ROOTUSER -p$ROOTPASS -e "CREATE USER '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASS';"
mysql -u$ROOTUSER -p$ROOTPASS -e "GRANT ALL PRIVILEGES ON \`$DBNAME\`.* TO '$DBUSER'@'localhost';"
mysql -u$ROOTUSER -p$ROOTPASS -e "FLUSH PRIVILEGES;"
