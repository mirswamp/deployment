#!/bin/bash

read -r -s -p "Enter the password for the 'root' DB user: " ROOTPASSWORD
echo

echo ""
echo "############################"
echo "##### File Permissions #####"
echo "############################"

echo ""
echo "Listing key configuration files"

ls -l /opt/swamp/etc/swamp.conf
ls -l /var/www/html/swamp-web-server/.env

echo ""
echo "Listing potential leftover DB password files"

ls -ld /etc/.*

echo ""
echo "####################"
echo "##### DB Users #####"
echo "####################"

echo ""
echo "Listing rows in mysql.user table"

mysql -u root -p"$ROOTPASSWORD" <<< 'SELECT User, Host, Password FROM mysql.user'

echo ""
echo "#####################"
echo "##### DB Tables #####"
echo "#####################"

echo ""
echo "Listing rows in mysql.db table"

mysql -u root -p"$ROOTPASSWORD" <<< 'SELECT Host, Db, User FROM mysql.db'

echo ""
echo "###############################"
echo "##### SWAMP User Accounts #####"
echo "###############################"

echo ""
echo "Listing rows in project.user table"

mysql -u root -p"$ROOTPASSWORD" <<< 'SELECT Username, Password FROM project.user'

echo ""
echo "##########################################"
echo "##### SWAMP Web Server Configuration #####"
echo "##########################################"

echo ""
echo "You will need to enter your password for sudo."

sudo cat /var/www/swamp-web-server/.env | grep 'APP_ENV\|APP_KEY'
