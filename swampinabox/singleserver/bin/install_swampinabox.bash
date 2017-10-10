#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

#
# Install or upgrade SWAMP-in-a-Box on the current host.
#

BINDIR="$(dirname "$0")"
RELAYHOST="128.104.153.1"

. "$BINDIR/../sbin/swampinabox_install_util.functions"
. "$BINDIR/../sbin/getargs.function"

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
    getargs "-install $*" || exit 1
    SWAMP_LOGFILE="$SWAMP_LOGDIR/install_swampinabox_$NOW.log"
else
    getargs "-upgrade $*" || exit 1
    SWAMP_LOGFILE="$SWAMP_LOGDIR/upgrade_swampinabox_$NOW.log"
fi
ERROR_LOGFILE="${SWAMP_LOGFILE/.log/.errors}"

#
# Check that the requirements for the install have been met.
#
if [ "$(whoami)" != "root" ]; then
    echo "Error: The install/upgrade must be performed as 'root'." 1>&2
    echo "Perhaps run the install/upgrade script using 'sudo'." 1>&2
    exit 1
fi

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

if [ ! -d "$WORKSPACE/deployment/swamp" ]; then
    echo "Error: There is no 'deployment' directory in which to build RPMs." 1>&2
    echo "Create a workspace in a developer's home directory such as '/home/<user>/swamp'." 1>&2
    echo "Change to that directory and execute 'git_clone.bash'." 1>&2
    echo "Then execute '$0'." 1>&2
    exit 1
else
    echo "Found deployment directory: $WORKSPACE/deployment/swamp"
fi

#
# Save encrypted DB password(s) into files for use by other scripts.
# Minimize the chance of the passwords appearing in process listings.
#
reset_umask="$(umask -p)"
umask 377

echo "$DBPASSWORD" | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_root -pass pass:swamp
chmod 400 /etc/.mysql_root
echo "$DBPASSWORD" | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_web -pass pass:swamp
chmod 400 /etc/.mysql_web
echo "$DBPASSWORD" | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_java -pass pass:swamp
chmod 400 /etc/.mysql_java
echo "$SWAMPADMINPASSWORD" | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_admin -pass pass:swamp
chmod 400 /etc/.mysql_admin

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
            "-singleserver" \
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
else
    echo "FAILURE! The SWAMP for this installation *might* be available at:"
fi

echo ""
echo "    https://$HOSTNAME"
echo ""

exit $main_install_exit_code
