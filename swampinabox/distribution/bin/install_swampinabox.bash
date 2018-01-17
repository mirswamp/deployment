#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Install or upgrade SWAMP-in-a-Box on the current host.
#

BINDIR="$(dirname "$0")"
RELAYHOST=""

. "$BINDIR/../sbin/swampinabox_install_util.functions"

export ASSUME_RESPONSE="no"

#
# Ensure that temporary DB password files get removed.
#
trap 'stty echo; remove_db_password_files; exit 1' INT TERM

#
# Determine the install type, log file location, etc.
#
NOW="$(date +"%Y%m%d_%H%M%S")"

if [ -e "$BINDIR/../log" ]; then
    SWAMP_LOGDIR="$BINDIR/../log"
else
    SWAMP_LOGDIR="."
fi

if [[ "$0" =~ install_swampinabox ]]; then
    MODE="-install"
    SWAMP_LOGFILE="$SWAMP_LOGDIR/install_swampinabox_$NOW.log"
else
    MODE="-upgrade"
    SWAMP_LOGFILE="$SWAMP_LOGDIR/upgrade_swampinabox_$NOW.log"
fi
ERROR_LOGFILE="${SWAMP_LOGFILE/.log/.errors}"

WORKSPACE="$BINDIR/.."
read RELEASE_NUMBER BUILD_NUMBER SHORT_RELEASE_NUMBER < "$BINDIR/version.txt"

#
# Check that the requirements for the install have been met.
#
if [ "$(whoami)" != "root" ]; then
    echo "Error: The install/upgrade must be performed as 'root'." 1>&2
    echo "Perhaps run the install/upgrade script using 'sudo'." 1>&2
    exit 1
fi

for archive_file in \
        "$BINDIR/../../swampinabox-${SHORT_RELEASE_NUMBER}-tools.tar.gz" \
        "$BINDIR/../../swampinabox-${SHORT_RELEASE_NUMBER}-platforms.tar.gz" \
        ; do
    if [ ! -r "$archive_file" ]; then
        echo "Error: No such file (or file is not readable): $archive_file" 1>&2
        exit 1
    fi
done

if [ "$(getenforce)" == "Enforcing" ]; then
    echo "Error: SELinux is enforcing. The SWAMP will not function properly." 1>&2
    echo "You can disable SELinux by editing /etc/selinux/config," 1>&2
    echo "setting SELINUX=disabled, and then rebooting this host." 1>&2
    exit 1
fi

for prog in \
        cat cp ln rm df stty tail \
        chgrp chmod chown chsh \
        awk diff install sed patch \
        chkconfig service \
        compress gunzip jar rpm sha512sum tar yum zip \
        condor_history condor_q condor_reconfig condor_rm condor_status condor_submit \
        guestfish qemu-img virsh virt-copy-out virt-make-fs \
        mysql openssl perl php \
        ; do
    echo -n "Checking for '$prog' ... "
    if ! which "$prog" ; then
        echo "Error: '$prog' is not found in $USER's path." 1>&2
        echo "Check that the set up script for your system was run, or install '$prog'." 1>&2
        exit 1
    fi
done

"$BINDIR/../sbin/swamp_check_virtualization_support" \
    || exit 1

"$BINDIR/../sbin/swampinabox_check_prerequisites.pl" \
    "$MODE" \
    -distribution \
    -rpms "$BINDIR/../RPMS" \
    -version "$RELEASE_NUMBER" \
    || exit 1

echo ""
echo "====================================================================="
echo ""

# CSA-2866: Explicitly confirm that the detected hostname is correct.
# If required, set it here so that sub-scripts inherit the value.
if [ "$MODE" = "-install" ]; then
    echo "We found the following hostname(s) on the SSL certificates configured"
    echo "for this host's web server (this list is not necessarily complete):"
    echo ""

    potential_hostnames="$("$BINDIR/../sbin/swamp_get_potential_web_hosts")"
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
            export HOSTNAME="$answer"

            ip_address="$(perl -e 'use Socket; print inet_ntoa(inet_aton($ARGV[0]))' "$HOSTNAME" 2>/dev/null)"

            if [ $? -ne 0 ]; then
                echo "Error: Unable to determine an IP address for: $HOSTNAME" 1>&2
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
        echo "Error: No SWAMP-in-a-Box installation to upgrade." 1>&2
        echo "Run the install script to set up a new SWAMP-in-a-Box." 1>&2
        exit 1
    fi

    # Use the hostname that is currently configured for the web server.
    echo "Extracting hostname from '/var/www/swamp-web-server/.env'"
    export HOSTNAME=$(grep '^\s*APP_URL\s*=' '/var/www/swamp-web-server/.env' | sed 's/^\s*APP_URL\s*=\s*https\?:\/\/\([^/]*\)\/\?\s*$/\1/')
    echo "\$HOSTNAME has been set to: $HOSTNAME"
fi

echo ""
for other_hostname in \
        localhost \
        localhost.localdomain \
        ; do
    echo -n "Testing that '$other_hostname' resolves to an IP address ... "

    ip_address="$(perl -e 'use Socket; print inet_ntoa(inet_aton($ARGV[0]))' "$other_hostname" 2>/dev/null)"

    if [ $? -eq 0 ]; then
        echo "$ip_address"
    else
        echo "Error: Unable to determine an IP address for: $other_hostname" 1>&2
        exit 1
    fi
done

#
# Query for user-configurable parameters and perform the install.
#
function ask_pass() {
    PROMPT="$1"
    if [ "$2" = "-confirm" ]; then NEED_CONFIRM=1; else NEED_CONFIRM=0; fi
    NEED_PASSWORD=1

    while [ "$NEED_PASSWORD" -eq 1 ]; do
        ANSWER=""
        CONFIRMATION=""

        read -r -e -s -p "$PROMPT " ANSWER
        echo

        if [ -z "$ANSWER" ]; then
            echo "*** Password cannot be empty. ***" 1>&2
        else
            if [ "$NEED_CONFIRM" -eq 1 ]; then
                stty -echo
                echo -n "Retype password: "
                read -r CONFIRMATION
                echo
                stty echo

                if [ "$ANSWER" != "$CONFIRMATION" ]; then
                    echo "*** Passwords do not match. ***" 1>&2
                else
                    NEED_PASSWORD=0
                fi
            else
                NEED_PASSWORD=0
            fi
        fi
    done
}

function test_db_password() {
    username="$1"
    password="$2"
    cnffile="/opt/swamp/sql/sql.cnf"

    #
    # In the options file for MySQL:
    #   - Quote the values, in case they contain '#'.
    #   - Escape backslashes (the only character that needs escaping).
    #
    # See: http://dev.mysql.com/doc/refman/5.7/en/option-files.html
    #
    password=${password//\\/\\\\}
    username=${username//\\/\\\\}

    echo '[client]' > "$cnffile"
    chmod 400 "$cnffile"
    echo "password='$password'" >> "$cnffile"
    echo "user='$username'" >> "$cnffile"

    mysql --defaults-file="$cnffile" <<< ';'
    success=$?

    rm -f "$cnffile"

    if [ $success -ne 0 ]; then
        echo "Error: Failed to log into the database as '$username'" 1>&2
        return 1
    fi

    return 0
}

echo ""
echo "====================================================================="
echo ""

if [ "$MODE" = "-install" ]; then
    ask_pass "Enter database root password (DO NOT FORGET!):" -confirm
    DBROOT="$ANSWER"

    ask_pass "Enter database web password:"
    DBWEB="$ANSWER"

    ask_pass "Enter database SWAMP services password:"
    DBJAVA="$ANSWER"

    ask_pass "Enter SWAMP administrator account password:"
    SWAMPADMIN="$ANSWER"

    #
    # The only place the SWAMP admin password gets used is in initializing the
    # corresponding user record in the database. So, it's safe to set it here to
    # the final string that should be stored.
    #
    SWAMPADMIN=${SWAMPADMIN//\\/\\\\}
    SWAMPADMIN=${SWAMPADMIN//\'/\\\'}
    SWAMPADMIN="{BCRYPT}$(php -r "echo password_hash('$SWAMPADMIN', PASSWORD_BCRYPT);")"

    # MYDOMAIN=$(dnsdomainname)
    # EMAIL="no-reply@${MYDOMAIN}"
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
        DBROOT="$ANSWER"

        test_db_password root "$DBROOT"
        success=$?
    done
fi

#
# Save encrypted DB password(s) into files for use by other scripts.
# Minimize the chance of the passwords appearing in process listings.
#
reset_umask="$(umask -p)"
umask 377

echo "$DBROOT" | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_root -pass pass:swamp
chmod 400 /etc/.mysql_root

if [ "$MODE" = "-install" ]; then
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
echo ""
echo "====================================================================="
echo ""
{
  {
    {
      { "$BINDIR/../sbin/swampinabox_do_install.bash" \
            "$WORKSPACE" \
            "$RELEASE_NUMBER" \
            "$BUILD_NUMBER" \
            "$RELAYHOST" \
            "$MODE" \
            "$SWAMP_LOGFILE" \
            "-distribution" \
            "$SHORT_RELEASE_NUMBER" \
            "$ERROR_LOGFILE" \
            3>&1 1>&2 2>&3 3>&-;
        echo $? 1>&8;
      } | tee "$ERROR_LOGFILE";
    } |& tee "$SWAMP_LOGFILE" 1>&9;
  } 8>&1 | (read original_exit_code ; exit "${original_exit_code:-1}");
} 9>&1

main_install_exit_code=$?

chmod a-wx "$SWAMP_LOGFILE" "$ERROR_LOGFILE"

echo ""
echo "====================================================================="
echo ""
echo "Output from this install is available in:"
echo ""

if [ -d /opt/swamp/log ]; then
    cp "$SWAMP_LOGFILE" /opt/swamp/log
    cp "$ERROR_LOGFILE" /opt/swamp/log
    echo "  /opt/swamp/log/$(basename "$SWAMP_LOGFILE")"
    echo "  /opt/swamp/log/$(basename "$ERROR_LOGFILE")"
else
    echo "  $SWAMP_LOGFILE"
    echo "  $ERROR_LOGFILE"
fi

echo ""
echo "Please preserve these files. They will be helpful in debugging"
echo "any issues that you might encounter with this install."
echo ""

if [ $main_install_exit_code -eq 0 ]; then
    echo "The SWAMP for this installation should be available at:"
    echo ""
    echo "    https://$HOSTNAME"
    echo ""
else
    echo "The SWAMP for this installation *might* be available at:"
    echo ""
    echo "    https://$HOSTNAME"
    echo ""
    echo "WARNING: Errors were encountered during the install process."
fi

exit $main_install_exit_code
