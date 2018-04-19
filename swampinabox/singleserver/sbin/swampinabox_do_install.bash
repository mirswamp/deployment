#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Install or upgrade SWAMP-in-a-Box on the current host.
#

encountered_error=0
trap 'encountered_error=1; echo "Error (unexpected): In $(basename "$0"): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BINDIR=$(dirname "$0")
workspace=$1
release_number=$2
build_number=$3
relay_host=$4
mode=$5
swamp_log_file=$6
swamp_context=$7

#
# Ensure that temporary DB password files get removed.
#
source "$BINDIR/swampinabox_install_util.functions"
trap 'stty echo ; remove_db_password_files' EXIT
trap 'stty echo ; remove_db_password_files ; exit 1' INT TERM

############################################################################

function check_for_prog() {
    prog=$1
    echo -n "Checking for $prog ... "
    if ! which "$prog" ; then
        echo "" 1>&2
        echo "Error: '$prog' is not in $USER's path" 1>&2
        echo "Check that the set up script for your system was run, or install '$prog'." 1>&2
        exit 1
    fi
}

function get_full_path() {
    path=$1
    if [ -z "$path" ]; then
        echo "$path"
    elif [ -d "$path" ]; then
        (cd "$path" ; pwd)
    elif [ -d "$(dirname "$path")" ]; then
        echo "$(cd "$(dirname "$path")" ; pwd)/$(basename "$path")"
    else
        echo "$path"
    fi
}

function get_ip_addr() {
    perl -e 'use Socket; print inet_ntoa(inet_aton($ARGV[0]))' "$1"
}

function replace_suffix() {
    path=$1
    old_suffix=$2
    new_suffix=$3
    echo "$(dirname "$path")/$(basename "$path" "$old_suffix")$new_suffix"
}

function echo_separator() {
    echo ""
    echo "#####################################################################"
    echo ""
}

function echo_title() {
    echo ""
    echo ""
    echo "### $1"
    echo ""
}

echo ""
echo "Starting the main SWAMP-in-a-Box install/upgrade script"
echo "Release $release_number, build $build_number"
echo ""
echo "Installer mode: $mode $swamp_context"
echo "Effective user/group: $(id -u)/$(id -g) ($(id -un)/$(id -gn))"
echo "Current umask: $(umask)"
echo ""
echo "\$HOSTNAME:   $HOSTNAME"
echo "\$(hostname): $(hostname)"
echo "Relay host:  $relay_host"
echo "Workspace:   $(get_full_path "$workspace")"
echo "Working dir: $(pwd)"

case "$mode" in
    -install) install_or_upgrade="install" ;;
    -upgrade) install_or_upgrade="upgrade" ;;
    *)        install_or_upgrade="install/upgrade" ;;
esac

############################################################################

#
# The install will be performed as 'root', so make sure we perform the
# various pre-install checks as 'root'.
#
if [ "$(whoami)" != "root" ]; then
    echo "" 1>&2
    echo "Error: The $install_or_upgrade must be performed as 'root'." 1>&2
    echo "Perhaps run the $install_or_upgrade script using 'sudo'." 1>&2
    exit 1
fi

#
# Check for the programs used by the first few pre-install checks.
#
echo ""
for prog in grep lsmod rpm ; do check_for_prog "$prog" ; done

#
# Check for virtualization support before everything else because it is
# a fairly low-level, non-negotiable requirement for the host.
#
echo ""
"$BINDIR/swamp_check_virtualization_support" || exit 1

############################################################################

#
# Validate performing an install vs. upgrade.
#
for pkg in swampinabox-backend swamp-web-server ; do
    version=$(get_rpm_version "$pkg")

    if [ "$mode" = "-install" ] && [ ! -z "$version" ]; then
        echo_separator
        echo "SWAMP-in-a-Box version $version appears to be installed."
        echo "Performing an install will erase existing data and configuration."
        echo ""
        read -r -p "Are you sure you want to install version $release_number? [N/y] " answer
        echo "" 1>&2

        if [ "$answer" != "y" ]; then
            exit 1
        fi
        break
    fi
    if [ "$mode" = "-upgrade" ] && [ -z "$version" ]; then
        echo "" 1>&2
        echo "Error: The $pkg RPM is not installed" 1>&2
        echo "Perhaps run the SWAMP-in-a-Box *install* script." 1>&2
        exit 1
    fi
    if [ "$mode" = "-upgrade" ] && [[ "$version" =~ ^(1.27|1.28) ]]; then
        echo "" 1>&2
        echo "Error: Upgrading from $version is not supported" 1>&2
        echo "Perhaps upgrade to an earlier SWMAP-in-a-Box release first." 1>&2
        exit 1
    fi
done

if [ "$mode" = "-upgrade" ] && [ ! -f /var/www/swamp-web-server/.env ]; then
    echo "" 1>&2
    echo "Error: No such file: /var/www/swamp-web-server/.env" 1>&2
    echo "Error: Cannot upgrade a corrupted installation" 1>&2
    exit 1
fi

############################################################################

#
# Check the host's software setup.
#
if [ "$(getenforce)" = "Enforcing" ]; then
    echo "" 1>&2
    echo "Error: SELinux is enforcing. The SWAMP will not function properly." 1>&2
    echo "To disable SELinux, do the following:" 1>&2
    echo "" 1>&2
    echo "   1. Edit /etc/selinux/config and set SELINUX=disabled." 1>&2
    echo "   2. Reboot this host." 1>&2
    exit 1
fi

if [ "$swamp_context" = "-singleserver" ]; then
    yum_install_log_file=$(replace_suffix "$swamp_log_file" .log .yum_install.log)

    echo_title "Running yum_install.bash"
    echo "Logging the 'yum install's to: $(get_full_path "$yum_install_log_file")"

    if ! "$BINDIR/yum_install.bash" > "$yum_install_log_file" 2>&1 ; then
        echo "" 1>&2
        echo "Error: Failed to install some required packages" 1>&2
        echo "Consult the log file above for details." 1>&2
        exit 1
    fi
fi

echo ""
for prog in \
        basename cat cp dirname head ln lsmod rm df stty tail \
        chgrp chmod chown chsh groupadd groupmems \
        awk diff install sed patch \
        chkconfig service \
        compress gunzip jar rpm sha512sum tar unzip yum zip \
        condor_history condor_q condor_reconfig condor_rm condor_status condor_submit \
        guestfish qemu-img virsh virt-copy-out virt-make-fs \
        curl mysql openssl perl php \
        ; do
    check_for_prog "$prog"
done

echo ""
"$BINDIR/swamp_check_hardware" "$mode" "$swamp_context" -rpms "$BINDIR/../RPMS" || exit 1

echo ""
for other_hostname in localhost localhost.localdomain ; do
    echo -n "Determining the IP address of $other_hostname ... "
    if ! get_ip_addr "$other_hostname" ; then
        echo "" 1>&2
        echo "Error: Unable to determine an IP address for $other_hostname" 1>&2
        exit 1
    fi
    echo ""
done

if [ "$swamp_context" = "-distribution" ]; then
    for archive_file in \
            "$BINDIR/../../swampinabox-${release_number}-tools.tar.gz" \
            "$BINDIR/../../swampinabox-${release_number}-platforms.tar.gz" \
            ; do
        if [ ! -f "$archive_file" ]; then
            echo "" 1>&2
            echo "Error: No such file: $archive_file" 1>&2
            exit 1
        fi
    done
fi

############################################################################

#
# CSA-2866: Explicitly confirm that the detected hostname is correct.
# If required, set it here so that sub-scripts inherit the value.
#
if [ "$mode" = "-install" ] && [ "$swamp_context" = "-distribution" ]; then
    echo_separator
    echo "We found the following hostname(s) on the SSL certificates configured"
    echo "for this host's web server (this list is not necessarily complete):"
    echo ""

    potential_hostnames="$("$BINDIR/swamp_get_potential_web_hosts")"
    while read -r potential_hostname ; do
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
    read -r -p "Use $HOSTNAME as this host's DNS name? [N/y] " answer
    echo "" 1>&2

    if [ "$answer" != "y" ]; then
        need_hostname=1
        while [ "$need_hostname" -eq 1 ]; do
            read -r -p "Enter the hostname to use: " answer
            echo "" 1>&2
            export HOSTNAME="$answer"

            echo -n "Determining the IP address of $HOSTNAME ... "
            if ! get_ip_addr "$HOSTNAME" ; then
                echo "" 1>&2
                echo "Error: Unable to determine an IP address for $HOSTNAME" 1>&2
            else
                need_hostname=0
            fi
            echo ""
        done
    fi
fi

if [ "$mode" = "-upgrade" ]; then
    # Use the hostname that is currently configured for the web server.
    echo ""
    echo "Extracting hostname from '/var/www/swamp-web-server/.env'"
    export HOSTNAME=$(grep '^\s*APP_URL\s*=' '/var/www/swamp-web-server/.env' | sed 's/^\s*APP_URL\s*=\s*https\?:\/\/\([^/]*\)\/\?\s*$/\1/')
    echo "\$HOSTNAME has been set to $HOSTNAME"
fi

############################################################################

#
# Query for (initial) passwords.
#
if [ "$mode" = "-install" ] && [ "$swamp_context" = "-distribution" ]; then
    echo_separator

    #
    # 'create_mysql_root' won't overwrite an existing file.
    #
    rm -f /etc/.mysql_root /etc/.mysql_web /etc/.mysql_java /etc/.mysql_admin

    #
    # Prompt for and save the database users' passwords.
    #
    "$BINDIR/create_mysql_root" /etc/.mysql_root \
        --prompt="Enter database root password (DO NOT FORGET!): " \
        --confirm
    "$BINDIR/create_mysql_root" /etc/.mysql_web \
        --prompt="Enter database web password: "
    "$BINDIR/create_mysql_root" /etc/.mysql_java \
        --prompt="Enter database SWAMP services password: "

    #
    # The only place the SWAMP admin password gets used is in initializing
    # the corresponding user record in the database. So, it's safe to set it
    # here to the encryped string that should be stored in the database.
    #
    "$BINDIR/create_mysql_root" /etc/.mysql_admin \
        --prompt="Enter SWAMP administrator account password: " \
        --php-bcrypt
elif [ "$mode" = "-upgrade" ] && [ "$swamp_context" = "-distribution" ]; then
    echo_separator

    #
    # 'create_mysql_root' won't overwrite an existing file.
    #
    rm -f /etc/.mysql_root

    #
    # Prompt for and save the database 'root' user's password.
    #
    "$BINDIR/create_mysql_root" /etc/.mysql_root \
        --prompt="Enter database root password: " \
        --test
fi
echo_separator

############################################################################

echo_title "Stopping Services"
"$BINDIR/manage_services.bash" stop

echo_title "Configuring /etc/hosts"
"$BINDIR/configure_hosts.bash"

if [ "$swamp_context" = "-singleserver" ]; then
    echo_title "Configuring Clock"
    "$BINDIR/configure_clock.bash" "$swamp_context"
fi

if [[ ! ( $(getent passwd mysql) =~ :/bin/bash$ ) ]]; then
    echo_title "Setting mysql User's Shell"
    chsh -s /bin/bash mysql
fi

#
# The "workspace" used by the RPM install script ($rpm_workspace) depends
# on whether we built the RPMs as part of the install.
#
if [ -x "$BINDIR/swampinabox_build_rpms.bash" ]; then
    rpm_build_log_file=$(replace_suffix "$swamp_log_file" .log .rpm_build.log)

    echo_title "Building RPMs"
    echo "Logging the build to: $(get_full_path "$rpm_build_log_file")"

    if ! "$BINDIR/swampinabox_build_rpms.bash" "singleserver" "$workspace" "$release_number" "$build_number" > "$rpm_build_log_file" 2>&1 ; then
        echo "" 1>&2
        echo "Error: Failed to build RPMs" 1>&2
        echo "Consult the log file above for details." 1>&2
        exit 1
    fi
    rpm_workspace="$workspace/deployment/swamp"
else
    rpm_workspace="$workspace"
fi

echo_title "Installing RPMs"
if ! "$BINDIR/swampinabox_install_rpms.bash" "$rpm_workspace" "$release_number" "$build_number" "$mode" ; then
    echo "" 1>&2
    echo "Error: Failed to install and/or configure SWAMP-in-a-Box RPMs" 1>&2
    exit 1
fi

echo_title "Installing Database Tables, Procedures, and Records"
if ! "$BINDIR/swampinabox_install_database.bash" "$mode" "$swamp_context" ; then
    echo "" 1>&2
    echo "Error: Failed to install SWAMP database tables, procedures, and records" 1>&2
    exit 1
fi

echo_title "Configuring Apache (httpd)"
"$BINDIR/configure_httpd.bash"

echo_title "Configuring HTCondor"
"$BINDIR/configure_htcondor.bash"

echo_title "Setting Hostname in the SWAMP Configuration"
/opt/swamp/bin/swamp_set_db_host        --hostname="localhost"
/opt/swamp/bin/swamp_set_htcondor_host  --hostname="localhost"
/opt/swamp/bin/swamp_set_web_host       --hostname="$HOSTNAME" --force

if [ "$mode" = "-install" ]; then
    echo_title "Setting Initial Passwords"
    "$BINDIR/swampinabox_patch_passwords.pl" token
fi

if [ "$mode" = "-install" ] && [ "$swamp_context" = "-singleserver" ]; then
    echo_title "Configuring Email"
    "$BINDIR/configure_mail.bash" "$swamp_context" "$relay_host"
fi

echo_title "Configuring SWAMP Filesystem"
"$BINDIR/swampinabox_make_filesystem.bash"

echo_title "Installing Platforms"
"$BINDIR/swamp_install_platforms.bash" "$swamp_context" "$release_number"
/opt/swamp/sbin/rebuild_platforms_db

echo_title "Installing Tools"
"$BINDIR/swamp_install_tools.bash" "$swamp_context" "$release_number"
/opt/swamp/sbin/rebuild_tools_db "$swamp_context"

if [ -f /opt/swamp/thirdparty/codedx/vendor/codedx.war ]; then
    echo_title "Installing Code Dx"
    /opt/swamp/bin/install_codedx
fi

echo_title "Configuring sudo and libvirt"
"$BINDIR/configure_sudo_libvirt.bash"

#
# CSA-2714: On CentOS 6, manage_services.bash causes mysqld_safe to start
# running, which keeps its standard error stream open for writing. In order
# to pipe the output from this script safely, we need to ensure that that
# stream isn't shared with this script's standard error stream.
#
echo_title "Restarting Services"
coproc services_fds { "$BINDIR/manage_services.bash" restart 2>&1; }

exec {services_fd}<&${services_fds[0]}

success=0
while [ $success -eq 0 ]; do
    if read -r -d '' -n 1 -t 1 -u "${services_fd}" ; then
        success=0
    else
        success=1
    fi
    echo -n "$REPLY"
    if [ $success -ne 0 ] && [ ! -z "${services_fds[0]}" ]; then
        # Keep waiting as long as manage_services.bash is alive.
        success=0
    fi
done

#
# Clean up and report the final disposition of the install/upgrade.
# At this point, there should be no further need for the ERR trap.
#
remove_db_password_files
trap '' ERR

echo_title "Running post-$install_or_upgrade checks"

/opt/swamp/bin/swamp_check_install --hostname="$HOSTNAME" --wait-for-condor
check_install_outcome=$?

echo ""

if [ $check_install_outcome -eq 1 ]; then
    echo "Error: The $install_or_upgrade process has completed, but with errors."
    exit $check_install_outcome
elif [ $check_install_outcome -eq 2 ]; then
    echo "Warning: The $install_or_upgrade process has completed, but with warnings"
    exit $check_install_outcome
elif [ $encountered_error -ne 0 ]; then
    echo "Error: The $install_or_upgrade process has completed, but with unknown errors"
    exit $encountered_error
fi

echo "The $install_or_upgrade process has completed."
exit $encountered_error
