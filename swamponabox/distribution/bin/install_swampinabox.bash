#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

BINDIR=`dirname $0`

if [[ "$0" =~ "install_swampinabox" ]]; then
    MODE="-install"
else
    MODE="-upgrade"
fi

WORKSPACE="$BINDIR/../swampsrc"
read RELEASE_NUMBER BUILD_NUMBER < $BINDIR/version.txt

$BINDIR/../sbin/swampinabox_check_prerequisites.bash "$MODE" -check-hardware || exit 1

#
# Define helper functions.
#

function remove_db_password_files {
    for file in \
            /etc/.mysql_root \
            /etc/.mysql_web \
            /etc/.mysql_java \
            /etc/.mysql_admin; do
        echo "Removing $file"
        rm -f "$file"
    done
}

function abort_install {
    echo ""
    echo "Aborting installation"

    remove_db_password_files

    echo ""
    echo "Installation is not complete."
    exit 1
}

#
# Query for user-configurable parameters and perform the install.
#

ask_pass() {
    PROMPT=$1
    if [ "$2" = "-confirm" ]; then NEED_CONFIRM=1; else NEED_CONFIRM=0; fi
    NEED_PASSWORD=1

    while [ "$NEED_PASSWORD" -eq 1 ]; do
        ANSWER=""
        CONFIRMATION=""

        read -r -e -s -p "$PROMPT " ANSWER
        echo

        if [ -z "$ANSWER" ]; then
            echo "*** Password cannot be empty. ***"
        else
            if [ "$NEED_CONFIRM" -eq 1 ]; then
                stty -echo
                echo -n "Retype password: "
                read -r CONFIRMATION
                echo
                stty echo

                if [ "$ANSWER" != "$CONFIRMATION" ]; then
                    echo "*** Passwords do not match. ***"
                else
                    NEED_PASSWORD=0
                fi
            else
                NEED_PASSWORD=0
            fi
        fi
    done
}

function test_db_password {
    username="$1"
    password="$2"
    mysql_cnf="/etc/.mysql_$username.cnf"

    #
    # In the options file for MySQL:
    #   - Quote the password, in case it contains '#'.
    #   - Escape backslashes (the only character that needs escaping).
    #
    # See: http://dev.mysql.com/doc/refman/5.7/en/option-files.html
    #
    password=${password//\\/\\\\}

    echo '[client]' > "$mysql_cnf"
    chmod 400 "$mysql_cnf"
    echo "password='$password'" >> "$mysql_cnf"
    echo "user='$username'" >> "$mysql_cnf"

    mysql --defaults-file="$mysql_cnf" <<< ';'
    success=$?

    rm -f "$mysql_cnf"

    if [ $success -ne 0 ]; then
        echo "Error: Failed to log into the database as $username"
        return 1
    fi

    return 0
}

echo ""

if [ "$MODE" == "-install" ]; then
    ask_pass "Enter database root password (DO NOT FORGET!):" -confirm
    DBROOT=$ANSWER

    ask_pass "Enter database web password:"
    DBWEB=$ANSWER

    ask_pass "Enter database SWAMP services password:"
    DBJAVA=$ANSWER

    ask_pass "Enter SWAMP-in-a-Box administrator account password:"
    SWAMPADMIN=$ANSWER

    #
    # The only place the SWAMP admin password gets used is in initializing the
    # corresponding user record in the database. So, it's safe to set it here to
    # the final string that should be stored.
    #
    SWAMPADMIN=${SWAMPADMIN//\\/\\\\}
    SWAMPADMIN=${SWAMPADMIN//\'/\\\'}
    SWAMPADMIN="{BCRYPT}$(php -r "echo password_hash('$SWAMPADMIN', PASSWORD_BCRYPT);")"

    MYDOMAIN=`dnsdomainname`
    EMAIL="no-reply@${MYDOMAIN}"
    # echo -n "Enter swamp reply email address: [$EMAIL] "
    # read -r ANSWER
    # if [ ! -z "$ANSWER" ]; then
    #     EMAIL=$ANSWER
    # fi

    RELAYHOST="\$mydomain"
    # echo -n "Enter postfix relay host: [$RELAYHOST] "
    # read -r ANSWER
    # if [ ! -z "$ANSWER" ]; then
    #     RELAYHOST=$ANSWER
    # fi
else
    success=1
    while [ $success -ne 0 ]; do
        ask_pass "Enter database root password:"
        DBROOT=$ANSWER

        test_db_password root "$DBROOT"
        success=$?
    done
fi

echo ""
echo "===================================="
echo "=== SWAMP-in-a-Box Configuration ==="
echo "===================================="
echo "Release number: $RELEASE_NUMBER"
echo "Build number: $BUILD_NUMBER"
# echo "Reply-to email address: $EMAIL"
# echo "Postfix relay host: $RELAYHOST"

echo ""
echo "#############################"
echo "##### Stopping Services #####"
echo "#############################"
$BINDIR/../sbin/manage_services.bash stop

if [ "$MODE" == "-install" ]; then

    echo ""
    echo "######################################"
    echo "##### Setting mysql User's Shell #####"
    echo "######################################"
    chsh -s /bin/bash mysql

    echo ""
    echo "##################################"
    echo "##### Configuring /etc/hosts #####"
    echo "##################################"
    $BINDIR/../sbin/hosts_configure.bash

    echo ""
    echo "#############################"
    echo "##### Configuring Clock #####"
    echo "#############################"
    $BINDIR/../sbin/clock_configure.bash

    echo ""
    echo "###############################################"
    echo "##### Installing and Configuring HTCondor #####"
    echo "###############################################"
    $BINDIR/../sbin/condor_install.bash || abort_install

fi

echo ""
echo "###########################################"
echo "##### Setting Database Password Files #####"
echo "###########################################"
echo "$DBROOT" | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_root -pass pass:swamp
chmod 400 /etc/.mysql_root

if [ "$MODE" == "-install" ]; then
    echo "$DBWEB" | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_web -pass pass:swamp
    chmod 400 /etc/.mysql_web
    echo "$DBJAVA" | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_java -pass pass:swamp
    chmod 400 /etc/.mysql_java
    echo "$SWAMPADMIN" | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_admin -pass pass:swamp
    chmod 400 /etc/.mysql_admin
fi

echo ""
echo "###########################"
echo "##### Installing RPMS #####"
echo "###########################"
$BINDIR/../sbin/swampinabox_install_rpms.bash \
        $WORKSPACE \
        $RELEASE_NUMBER \
        $BUILD_NUMBER \
        $EMAIL \
        $MODE \
    || abort_install

echo ""
echo "##########################################"
echo "##### Performing Database Operations #####"
echo "##########################################"
$BINDIR/../sbin/swampinabox_install_database.bash $MODE || abort_install

if [ "$MODE" == "-install" ]; then

    echo ""
    echo "#######################################"
    echo "##### Patching Database Passwords #####"
    echo "#######################################"
    $BINDIR/../sbin/swampinabox_patch_passwords.pl token

fi

echo ""
echo "#############################"
echo "##### Configuring Email #####"
echo "#############################"
$BINDIR/../sbin/mail_configure.bash $RELAYHOST

echo ""
echo "########################################"
echo "##### Configuring sudo and libvirt #####"
echo "########################################"
$BINDIR/../sbin/sudo_libvirt.bash

echo ""
echo "########################################"
echo "##### Configuring SWAMP Filesystem #####"
echo "########################################"
$BINDIR/../sbin/swampinabox_make_filesystem.bash

echo ""
echo "################################"
echo "##### Installing Platforms #####"
echo "################################"
$BINDIR/../sbin/swamp_install_platforms.bash

echo ""
echo "############################"
echo "##### Installing Tools #####"
echo "############################"
$BINDIR/../sbin/swamp_install_tools.bash

echo ""
echo "############################################"
echo "##### Removing Database Password Files #####"
echo "############################################"
remove_db_password_files

echo ""
echo "###############################"
echo "##### Restarting Services #####"
echo "###############################"
#
# CSA-2714: On CentOS 6, manage_services.bash causes mysqld_safe to start
# running, which keeps its standard error stream open for writing. In order
# to pipe the output from this script safely, we need to ensure that that
# stream isn't shared with this script's standard error stream.
#
coproc services_fds { $BINDIR/../sbin/manage_services.bash restart 2>&1; }

exec {services_fd}<&${services_fds[0]}

success=0
while [ $success -eq 0 ]; do
    read -r -d '' -n 1 -t 1 -u ${services_fd}
    success=$?
    echo -n "$REPLY"
    if [ $success -ne 0 -a ! -z "${services_fds[0]}" ]; then
        # Keep waiting as long as manage_services.bash is alive.
        success=0
    fi
done

echo ""
echo "##################################"
echo "##### Listing IPTABLES Rules #####"
echo "##################################"
iptables --list-rules

echo ""
echo "############################################"
echo "##### Listing Installation Diagnostics #####"
echo "############################################"
echo "SELinux: `getenforce`"
echo ""
echo "==========================="
echo "=== yum Repository List ==="
echo "==========================="
yum repolist
echo ""
echo "=========================="
echo "=== Installed Packages ==="
echo "=========================="
yum list installed | egrep 'mariadb|php|swamp'
echo ""
echo "==========================================="
echo "=== Web Configuration: swamp-web-server ==="
echo "==========================================="
cat /var/www/swamp-web-server/.env | grep -v -i 'password[ ]*='
echo ""
echo "==============================="
echo "=== Web Configuration: html ==="
echo "==============================="
cat /var/www/html/scripts/config.js
echo ""
echo "============================="
echo "=== Backend Configuration ==="
echo "============================="
cat /opt/swamp/etc/swamp.conf | grep -v -i 'pass[ ]*='
echo ""
echo "====================="
echo "=== System Health ==="
echo "====================="
/opt/perl5/perls/perl-5.18.1/bin/perl $BINDIR/../health_scripts/swamphealth.pl -all

echo ""
echo "###############################################"
echo "##### SWAMP-in-a-Box Install Has Finished #####"
echo "###############################################"
echo ""
echo "SWAMP-in-a-Box should be available the following URL:"
echo "https://$HOSTNAME"
