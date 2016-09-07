#!/bin/bash
BINDIR=`dirname $0`

# sets global variable ANSWER
function read_password() {
	which="$1"
	user="$2"
	confirm="$3"
	prompt="Enter $which $user password (empty string to skip): "
	if [ "$confirm" == "noconfirm" ]; then
		prompt="Enter $which password for $user (empty string to exit): "
	fi
	read -s -e -r -p "$prompt" ANSWER
	echo ""
	if [ -z "$ANSWER" ]; then
		return
	fi
	if [ "$confirm" == "noconfirm" ]; then
		return
	fi
	prompt="Confirm $which password for $user: "
	read -s -e -r -p "$prompt" CONFIRM
	echo ""
	if [ "$CONFIRM" != "$ANSWER" ]; then
		echo "Error - $user password confirmation failed"
		echo "Exiting ..."
		exit
	fi
}

# sets global variable OPTFILE
function configure_root_password() {
	echo '[client]' > /opt/swamp/sql/sql.cnf
	echo "user='root'" >> /opt/swamp/sql/sql.cnf
	echo "password='$DBROOT'" >> /opt/swamp/sql/sql.cnf
	chmod 400 /opt/swamp/sql/sql.cnf
	OPTFILE=--defaults-file=/opt/swamp/sql/sql.cnf
}

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
    echo "Error: $0 must be performed as root."
    echo "Exiting ..."
    exit
fi

# test for mysql service running
service mysql status
status=$?
if [ "$status" -ne 0 ]; then
	echo "Error: mysql is not running."
	echo "Exiting ..."
	exit
fi

read_password current "database root" noconfirm
if [ -z "$ANSWER" ]; then
	echo "Exiting ..."
	exit
fi
ANSWER=${ANSWER//\\/\\\\}
ANSWER=${ANSWER//\'/\\\'}
DBROOT="$ANSWER"

# test for mysql root access here
configure_root_password "$DBROOT"
result=`echo "SELECT user, host from mysql.user;" | mysql $OPTFILE 2>&1`
/bin/rm -f /opt/swamp/sql/sql.cnf
if [[ "$result" =~ ERROR ]]; then
	echo "Error: could not access mysql with root user."
	echo "Exiting ..."
	exit
fi

if [ "$DO_MYSQL" -eq 1 ]; then
	read_password new "database web" confirm
	if [ ! -z "$ANSWER" ]; then
		DBWEB="$ANSWER"
	    DBWEBESC=${ANSWER//\\/\\\\}
	    DBWEBESC=${DBWEBESC//\'/\\\'}
		read_password new "database SWAMP services" confirm
		if [ ! -z "$ANSWER" ]; then
			DBJAVA="$ANSWER"
    		DBJAVAESC=${ANSWER//\\/\\\\}
    		DBJAVAESC=${DBJAVAESC//\'/\\\'}
			echo "Setting new database web and java user passwords"
			# patch passwords in swamp.conf and .env
			echo "$DBWEB" | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_web -pass pass:swamp
			chmod 400 /etc/.mysql_web
			echo "$DBJAVA" | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_java -pass pass:swamp
			chmod 400 /etc/.mysql_java
			$BINDIR/../sbin/swamponabox_patch_passwords.pl
			rm -f /etc/.mysql_web
			rm -f /etc/.mysql_java
			
			# set passwords in mysql database user table
			configure_root_password "$DBROOT"
			echo "SET PASSWORD FOR 'web'@'%' = PASSWORD('${DBWEBESC}');" | mysql $OPTFILE mysql
			echo "SET PASSWORD FOR 'java_agent'@'%' = PASSWORD('${DBJAVAESC}');" | mysql $OPTFILE mysql
			echo "SET PASSWORD FOR 'java_agent'@'localhost' = PASSWORD('${DBJAVAESC}');" | mysql $OPTFILE mysql
			/bin/rm -f /opt/swamp/sql/sql.cnf
		fi
	fi
fi

if [ "$DO_SWAMPADMIN" -eq 1 ]; then
	read_password new "SWAMP-in-a-Box administrator account" confirm
	if [ ! -z "$ANSWER" ]; then
		ANSWER=${ANSWER//\\/\\\\}
		ANSWER=${ANSWER//\'/\\\'}
		SWAMPADMIN=$(php -r "echo password_hash('$ANSWER', PASSWORD_BCRYPT);")
		echo "Setting new admin-s user password"
		# set admin-s password in projects database user table
		configure_root_password "$DBROOT"
		echo "UPDATE user SET password='{BCRYPT}${SWAMPADMIN}' WHERE username='admin-s';" | mysql $OPTFILE project
		/bin/rm -f /opt/swamp/sql/sql.cnf
	fi
fi

if [ "$DO_ROOT" -eq 1 ]; then
	# query change of mysql root password
	echo ""
	echo "Change database root password"
	read_password new "database root" confirm
	if [ ! -z "$ANSWER" ]; then
		ANSWER=${ANSWER//\\/\\\\}
		ANSWER=${ANSWER//\'/\\\'}
		NEWDBROOT="$ANSWER"
		echo "Setting new database root password"
		configure_root_password "$DBROOT"
		echo "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${NEWDBROOT}'); FLUSH PRIVILEGES;" | mysql $OPTFILE mysql
		/bin/rm -f /opt/swamp/sql/sql.cnf
	fi
fi
