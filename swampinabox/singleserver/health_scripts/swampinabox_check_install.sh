#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

CNFFILE="/opt/swamp/sql/sql.cnf"

function remove_password_files {
    /bin/rm -f "$CNFFILE"
}

trap "stty echo; remove_password_files; exit 1;" INT TERM EXIT

if [ "$(whoami)" != "root" ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

success=0
while [ "$success" -ne 1 ]; do
    read -r -s -p "Enter the password for the 'root' DB user: " DBROOT
    echo

    #
    # In the options file for MySQL:
    #   - Quote the password, in case it contains '#'.
    #   - Escape backslashes (the only character that needs escaping).
    #
    # See: http://dev.mysql.com/doc/refman/5.7/en/option-files.html
    #
    DBROOT_ESC=${DBROOT//\\/\\\\}

    echo '[client]' > "$CNFFILE"
    chmod 400 "$CNFFILE"
    echo "password='$DBROOT_ESC'" >> "$CNFFILE"
    echo "user='root'" >> "$CNFFILE"

    mysql --defaults-file="$CNFFILE" <<< ';'
    if [ $? -eq 0 ]; then
        success=1
    fi
done

echo ""
echo "####################"
echo "##### DB Users #####"
echo "####################"

echo ""
echo "Listing rows in mysql.user table (check for: no unnecessary users)"

echo ""
mysql --defaults-file="$CNFFILE" <<< 'SELECT User, Host, Password FROM mysql.user'

echo ""
echo "#####################"
echo "##### DB Tables #####"
echo "#####################"

echo ""
echo "Listing rows in mysql.db table (check for: no test databases)"

echo ""
mysql --defaults-file="$CNFFILE" <<< 'SELECT Host, Db, User FROM mysql.db'

echo ""
echo "###############################"
echo "##### SWAMP User Accounts #####"
echo "###############################"

echo ""
echo "Listing rows in project.user table (check for: encrypted passwords)"

echo ""
mysql --defaults-file="$CNFFILE" <<< 'SELECT Username, Password FROM project.user'

echo ""
echo "#######################################"
echo "##### SWAMP Backend Configuration #####"
echo "#######################################"

echo ""
echo "Listing build number (check for: up to date)"

echo ""
cat /opt/swamp/etc/swamp.conf | grep 'buildnumber'

echo ""
echo "##########################################"
echo "##### SWAMP Web Server Configuration #####"
echo "##########################################"

echo ""
echo "Listing APP_ENV and APP_KEY values (check for: reasonableness)"

echo ""
cat /var/www/swamp-web-server/.env | grep 'APP_ENV\|APP_KEY'

echo ""
echo "########################################"
echo "##### SWAMP-in-a-Box Documentation #####"
echo "########################################"

echo ""
echo "Listing SWAMP documentation directory (check for: populated)"

echo ""
ls -R /opt/swamp/doc

echo ""
echo "####################################"
echo "##### Assessment Result Parser #####"
echo "####################################"

echo ""
echo "Listing contents of resultparser.tar (check for: comm vs. noncomm)"

echo ""
tar tvf /opt/swamp/thirdparty/resultparser.tar

echo ""
echo "############################"
echo "##### File Permissions #####"
echo "############################"

echo ""
echo "Listing key configuration files (check for: file permissions)"

echo ""
ls -l /opt/swamp/etc/swamp.conf
ls -l /var/www/swamp-web-server/.env
ls -l /var/www/html/config/config.json

echo ""
echo "##########################"
echo "##### Password Files #####"
echo "##########################"

remove_password_files

echo ""
echo "Listing DB password files (check for: no files listed)"

echo ""
ls -ld /etc/.mysql*
ls -l /opt/swamp/sql/sql.cnf
ls -l "$CNFFILE"
