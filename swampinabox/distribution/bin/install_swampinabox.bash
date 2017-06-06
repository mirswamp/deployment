#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname $0`

. $BINDIR/../sbin/swampinabox_install_util.functions

export ASSUME_RESPONSE="no"

#
# Ensure that temporary DB password files get removed.
#
trap 'stty echo; remove_db_password_files 1>/dev/null 2>/dev/null; exit 1;' INT TERM EXIT

#
# Determine install type, log file location, etc.
#
NOW=$(date +"%Y%m%d_%H%M%S")

if [ -e "$BINDIR/../log" ]; then
    SWAMP_LOGDIR="$BINDIR/../log"
else
    SWAMP_LOGDIR="."
fi

if [[ "$0" =~ "install_swampinabox" ]]; then
    MODE="-install"
    SWAMP_LOGFILE="$SWAMP_LOGDIR/install_swampinabox_$NOW.log"
else
    MODE="-upgrade"
    SWAMP_LOGFILE="$SWAMP_LOGDIR/upgrade_swampinabox_$NOW.log"
fi

WORKSPACE="$BINDIR/.."
read RELEASE_NUMBER BUILD_NUMBER SHORT_RELEASE_NUMBER < $BINDIR/version.txt

#
# Check that requirements for the install have been met
#
if [ "$(whoami)" != "root" ]; then
    echo "Error: The install/upgrade must be performed as root."
    echo "Perhaps run the install/upgrade script using 'sudo'."
    exit 1
fi

for archive_file in \
        "$BINDIR/../../swampinabox-${SHORT_RELEASE_NUMBER}-tools.tar.gz" \
        "$BINDIR/../../swampinabox-${SHORT_RELEASE_NUMBER}-platforms.tar.gz" \
        ; do
    if [ ! -r "$archive_file" ]; then
        echo "Error: $archive_file does not exist or is not readable"
        exit 1
    fi
done

if [ "$(getenforce)" == "Enforcing" ]; then
    echo "Error: SELinux is enforcing and SWAMP will not function properly.";
    echo "You can disable SELinux by editing /etc/selinux/config";
    echo "and setting SELINUX=disabled, and then rebooting this host.";
    exit 1
fi

for prog in \
        cp ln rm df stty tail \
        chgrp chmod chown chsh \
        awk diff sed patch \
        chkconfig service \
        compress gunzip jar rpm tar yum zip \
        condor_history condor_q condor_rm condor_status condor_submit \
        guestfish qemu-img virsh virt-copy-out virt-make-fs \
        mysql openssl perl php; do
    echo -n "Checking for $prog ... "
    which $prog
    if [ $? -ne 0 ]; then
        echo ""
        echo "Error: $prog is not found in $USER's path."
        echo "Check that the set up script for your system was run, or install $prog."
        exit 1
    fi
done

$BINDIR/../sbin/swampinabox_check_prerequisites.pl \
    "$MODE" \
    -distribution \
    -rpms "$BINDIR/../RPMS" \
    -version "$RELEASE_NUMBER" \
    || exit 1

# CSA-2866: Explicitly confirm that detected hostname is correct.
# If required, set it here so that sub-scripts inherit the value.
if [ "$MODE" = "-install" ]; then
    echo ""
    echo "====================================================================="
    echo ""
    echo "We found the following hostname(s) on the SSL certificates configured"
    echo "for this host's web server (this list is not necessarily complete):"
    echo ""

    potential_hostnames=$($BINDIR/../sbin/swamp_get_potential_web_hosts)
    while read -r potential_hostname; do
        echo "    $potential_hostname"
    done <<< "$potential_hostnames"

    echo ""
    echo "We are currently using the following for this host's DNS name:"
    echo ""
    echo "    $HOSTNAME"
    echo ""
    echo "That hostname needs to be accessible to users and have a properly"
    echo "configured SSL certificate."
    echo ""
    echo -n "Use '$HOSTNAME' as this host's DNS name? [N/y] "
    read answer
    if [ "$answer" != "y" ]; then

        need_hostname=1
        while [ "$need_hostname" -eq 1 ]; do
            echo -n "Enter the hostname to use: "
            read answer
            export HOSTNAME=$answer

            ip_address=$(perl -e 'use Socket; print inet_ntoa(inet_aton($ARGV[0]))' "$HOSTNAME" 2>/dev/null)

            if [ $? -ne 0 ]; then
                echo "Error: Unable to determine an IP address for $HOSTNAME"
            else
                need_hostname=0
            fi
        done
    fi

    if [[ "$HOSTNAME" != *"."* ]]; then
        echo ""
        echo "Note: '$HOSTNAME' is not fully-qualified domain name."
        confirm_continue || exit 1
    fi
fi
if [ "$MODE" = "-upgrade" ]; then
    if [ ! -r "/var/www/swamp-web-server/.env" ]; then
        echo "Error: No SWAMP-in-a-Box installation to upgrade."
        echo "Run the install script to set up a new SWAMP-in-a-Box."
        exit 1
    fi

    # Use the hostname that is currently configured for the web server.
    echo ""
    echo "Extracting hostname from /var/www/swamp-web-server/.env"
    export HOSTNAME=$(grep '^\s*APP_URL\s*=' '/var/www/swamp-web-server/.env' | sed 's/^\s*APP_URL\s*=\s*https\?:\/\/\([^/]*\)\/\?\s*$/\1/')
    echo "\$HOSTNAME has been set to: $HOSTNAME"
fi

echo ""
for other_hostname in localhost localhost.localdomain; do
    echo -n "Testing that $other_hostname resolves to an IP address ... "

    ip_address=$(perl -e 'use Socket; print inet_ntoa(inet_aton($ARGV[0]))' "$other_hostname" 2>/dev/null)

    if [ $? -eq 0 ]; then
        echo $ip_address
    else
        echo "Error: Unable to determine an IP address for $other_hostname"
        exit 1
    fi
done

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
    cnffile="/opt/swamp/sql/sql.cnf"

    #
    # In the options file for MySQL:
    #   - Quote the password, in case it contains '#'.
    #   - Escape backslashes (the only character that needs escaping).
    #
    # See: http://dev.mysql.com/doc/refman/5.7/en/option-files.html
    #
    password=${password//\\/\\\\}

    echo '[client]' > "$cnffile"
    chmod 400 "$cnffile"
    echo "password='$password'" >> "$cnffile"
    echo "user='$username'" >> "$cnffile"

    mysql --defaults-file="$cnffile" <<< ';'
    success=$?

    rm -f "$cnffile"

    if [ $success -ne 0 ]; then
        echo "Error: Failed to log into the database as $username"
        return 1
    fi

    return 0
}

echo ""
echo "====================================================================="
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
echo "###########################################"
echo "##### Setting Database Password Files #####"
echo "###########################################"
reset_umask=$(umask -p)
umask 377

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

$reset_umask

#
# Execute the core of the install/upgrade process.
#
$BINDIR/../sbin/swampinabox_do_install.bash \
        "$WORKSPACE" \
        "$RELEASE_NUMBER" \
        "$BUILD_NUMBER" \
        "$RELAYHOST" \
        "$MODE" \
        "$SWAMP_LOGFILE" \
        "-distribution" \
        "$SHORT_RELEASE_NUMBER" \
    |& tee "$SWAMP_LOGFILE"
