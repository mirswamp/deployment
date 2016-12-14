#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

BINDIR=`dirname $0`

. $BINDIR/../sbin/swampinabox_install_util.functions

#
# Ensure that temporary DB password files get removed.
#
trap 'stty echo; remove_db_password_files 1>/dev/null 2>/dev/null; exit 1;' INT TERM EXIT

#
# Determine install type, log file location, etc.
#
NOW=$(date +"%Y%m%d_%H%M%S")

if [ -e "$BINDIR/../../log" ]; then
    SWAMP_LOGDIR="$BINDIR/../../log"
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

WORKSPACE="$BINDIR/../swampsrc"
read RELEASE_NUMBER BUILD_NUMBER < $BINDIR/version.txt

#
# Check that requirements for the install have been met
#
$BINDIR/../sbin/swampinabox_check_prerequisites.bash "$MODE" -distribution || exit 1

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
    |& tee "$SWAMP_LOGFILE"
