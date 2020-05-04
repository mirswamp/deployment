#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

# This script is used to decrement the last row of the MYSQL assessment table's
# database_version_no, after the first upgrade of swampinabox.
# Note that this script is only used by swamp developer, not for install or upgrade script use.
# By: Jieru Hu

function validate_result() {
    if [[ "$1" =~ ERROR ]]; then
	    echo "Error: mysql query failed."
	    echo "Exiting ..."
	    exit
    fi
    return 0
}

# check if the user runs with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root: sudo ./decrement_db_version.bash"
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

# ask for the database password
echo -n "Enter database root password: "
read -s ANSWER
if [ ! -z $ANSWER ]; then
    DBROOT=$ANSWER
fi

# test for mysql root access here
echo '[client]' > /opt/swamp/sql/sql.cnf
echo password=$DBROOT >> /opt/swamp/sql/sql.cnf
echo user=root >> /opt/swamp/sql/sql.cnf
chmod 400 /opt/swamp/sql/sql.cnf
opt=--defaults-file=/opt/swamp/sql/sql.cnf

# decrement the database version number in assessment database_version table
result=`echo "USE assessment;UPDATE database_version SET database_version_no=database_version_no-1 ORDER BY database_version_id DESC LIMIT 1;" | mysql $opt 2>&1`
validate_result $result
if [ $? -eq 0 ]; then
    echo -e "\nDecremented the last row of the MYSQL's assessment.database_version_no by one"
fi

# decrement the database version number in project database_version table
result=`echo "USE project;UPDATE database_version SET database_version_no=database_version_no-1 ORDER BY
database_version_id DESC LIMIT 1;" | mysql $opt 2>&1`
validate_result $result
if [ $? -eq 0 ]; then
    echo "Decremented the last row of the MYSQL's project.database_version_no by one"
fi

# remove the login
/bin/rm -f /opt/swamp/sql/sql.cnf
