#!/bin/bash
# vim: noexpandtab nolist

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

BINDIR=`dirname "$0"`
CNFFILE="/opt/swamp/sql/sql.cnf"
OPTFILE="--defaults-file=/opt/swamp/sql/sql.cnf"
MYSQL_JAVA="/etc/.mysql_java"
MYSQL_WEB="/etc/.mysql_web"

function is_service_running() {
	service "$1" status 2>/dev/null 1>/dev/null
}
function restart_service() {
	echo "Restarting $1 service"
	service "$1" restart
}
function remove_password_files {
	/bin/rm -f "$CNFFILE"
	/bin/rm -f "$MYSQL_JAVA"
	/bin/rm -f "$MYSQL_WEB"
}
trap "stty echo; remove_password_files; exit 1;" INT TERM EXIT

# sets global variable ANSWER
function read_password() {
	which="$1"
	user="$2"
	confirm="$3"

	while true; do
		if [ "$confirm" == "noconfirm" ]; then
			prompt="Enter $which $user password (empty string to exit): "
		else
			prompt="Enter $which $user password (empty string to skip): "
		fi
		read -s -e -r -p "$prompt" ANSWER
		echo ""
		if [ -z "$ANSWER" -o "$confirm" == "noconfirm" ]; then
			return
		fi

		prompt="Retype $which password for $user: "
		read -s -e -r -p "$prompt" CONFIRM
		echo ""
		if [ "$CONFIRM" != "$ANSWER" ]; then
			echo "Error: Passwords do not match."
		else
			return
		fi
	done
}

# assumes global variable DBROOT
function configure_root_password() {
	echo '[client]' > "$CNFFILE"
	chmod 400 "$CNFFILE"
	echo "user='root'" >> "$CNFFILE"
	echo "password='$DBROOT'" >> "$CNFFILE"
}

#
# Check for command-line arguments and prerequisites
#
DO_ROOT=1
DO_MYSQL=1
DO_SWAMPADMIN=1
for arg in "$@"
do
	if [ "$arg" == "-h" -o "$arg" == "?" -o "$arg" == "-help" ]; then
		echo "usage: $0 [-h|?|-help|root|admin]"
		exit
	fi
	if [ "$arg" == "root" ]; then
		DO_ROOT=1
		DO_MYSQL=0
		DO_SWAMPADMIN=0
	elif [ "$arg" == "admin" ]; then
		DO_ROOT=0
		DO_MYSQL=0
		DO_SWAMPADMIN=1
	fi
done

if [ "$(whoami)" != "root" ]; then
	echo "Error: $0 must be run as root"
	exit 1
fi

if ! is_service_running mysql; then
	echo "Error: mysql service is not running"
	exit 1
fi

#
# Query for and test current DB 'root' password
#
read_password current "database root" noconfirm
if [ -z "$ANSWER" ]; then
	exit
fi
ANSWER=${ANSWER//\\/\\\\}
ANSWER=${ANSWER//\'/\\\'}
DBROOT="$ANSWER"

configure_root_password
result=`echo "SELECT user, host FROM mysql.user;" | mysql $OPTFILE 2>&1`
remove_password_files

if [[ "$result" =~ ERROR ]]; then
	echo "Error: Could not log into the database (mysql) as the root user"
	exit 1
fi

#
# Change the DB 'web' password
#
if [ "$DO_MYSQL" -eq 1 ]; then
	echo ""
	read_password new "database web" confirm
	if [ ! -z "$ANSWER" ]; then
		DBWEB="$ANSWER"
		DBWEBESC=${ANSWER//\\/\\\\}
		DBWEBESC=${DBWEBESC//\'/\\\'}

		echo "$DBWEB" | sudo openssl enc -aes-256-cbc -salt -out "$MYSQL_WEB" -pass pass:swamp
		chmod 400 "$MYSQL_WEB"
		$BINDIR/../sbin/swampinabox_patch_passwords.pl

		configure_root_password
		echo "SET PASSWORD FOR 'web'@'%' = PASSWORD('${DBWEBESC}'); FLUSH PRIVILEGES;" | mysql $OPTFILE mysql
		remove_password_files
	fi
fi

#
# Change the DB 'java_agent' password
#
if [ "$DO_MYSQL" -eq 1 ]; then
	echo ""
	read_password new "database SWAMP services" confirm
	if [ ! -z "$ANSWER" ]; then
		DBJAVA="$ANSWER"
		DBJAVAESC=${ANSWER//\\/\\\\}
		DBJAVAESC=${DBJAVAESC//\'/\\\'}

		echo "$DBJAVA" | sudo openssl enc -aes-256-cbc -salt -out "$MYSQL_JAVA" -pass pass:swamp
		chmod 400 "$MYSQL_JAVA"
		$BINDIR/../sbin/swampinabox_patch_passwords.pl

		configure_root_password
		echo "SET PASSWORD FOR 'java_agent'@'%' = PASSWORD('${DBJAVAESC}'); FLUSH PRIVILEGES;" | mysql $OPTFILE mysql
		echo "SET PASSWORD FOR 'java_agent'@'localhost' = PASSWORD('${DBJAVAESC}'); FLUSH PRIVILEGES;" | mysql $OPTFILE mysql
		remove_password_files

		if is_service_running swamp; then
			restart_service swamp
		fi
	fi
fi

#
# Change the SWAMP 'admin-s' password
#
if [ "$DO_SWAMPADMIN" -eq 1 ]; then
    echo ""
	read_password new "SWAMP-in-a-Box administrator account" confirm
	if [ ! -z "$ANSWER" ]; then
		ANSWER=${ANSWER//\\/\\\\}
		ANSWER=${ANSWER//\'/\\\'}
		SWAMPADMIN=$(php -r "echo password_hash('$ANSWER', PASSWORD_BCRYPT);")
		echo "Setting new password for SWAMP admin-s user"
		configure_root_password
		echo "UPDATE user SET password='{BCRYPT}${SWAMPADMIN}' WHERE username='admin-s';" | mysql $OPTFILE project
		remove_password_files
	fi
fi

#
# Change the DB 'root' password
#
if [ "$DO_ROOT" -eq 1 ]; then
	echo ""
	echo "*** Changing database root password ***"
	echo ""
	read_password new "database root" confirm
	if [ ! -z "$ANSWER" ]; then
		ANSWER=${ANSWER//\\/\\\\}
		ANSWER=${ANSWER//\'/\\\'}
		NEWDBROOT="$ANSWER"
		echo "*** Setting new password for database root user ***"
		configure_root_password
		echo "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${NEWDBROOT}'); FLUSH PRIVILEGES;" | mysql $OPTFILE mysql
		remove_password_files
	fi
fi
