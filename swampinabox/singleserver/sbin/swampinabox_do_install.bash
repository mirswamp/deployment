#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

echo
echo "### Starting the Main SWAMP-in-a-Box Install/Upgrade Script"
echo

encountered_error=0
trap 'encountered_error=1 ; echo "Error (unexpected): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "$0")" && pwd)
RUNTIME=$BINDIR/runtime
. "$RUNTIME"/bin/swamp_utility.functions

#
# Ensure that temporary DB password files get removed.
#
remove_db_password_files() {
    rm -f /etc/.mysql_root  \
          /etc/.mysql_web   \
          /etc/.mysql_java  \
          /etc/.mysql_admin \
          /opt/swamp/sql/sql.cnf
    stty echo 1>/dev/null 2>&1 || :
}
trap 'remove_db_password_files' EXIT

############################################################################

mode=$1
swamp_context=$2
version=$3
build=$4
rpms_dir=$5

cat <<EOF
Started:     $(date +"%Y-%m-%d %H:%M:%S %z")
Version:     $version (build $build)
Mode:        $mode $swamp_context
User/group:  $(id -u)/$(id -g) ($(id -un)/$(id -gn))
Umask:       $(umask)
\$HOSTNAME:   $HOSTNAME

RPMs directory: $rpms_dir
Working directory: $(pwd)

EOF

case "$mode" in
    -install) install_or_upgrade=install ;;
    -upgrade) install_or_upgrade=upgrade ;;
    *)        install_or_upgrade=install/upgrade ;;
esac

############################################################################

#
# The install will be performed as 'root', so make sure we perform the
# various pre-install checks as 'root'. Also check for 'perl', so that
# downstream scripts may assume that it is available.
#
if [ "$(whoami)" != "root" ]; then
    echo "Error: The $install_or_upgrade must be run as 'root'" 1>&2
    echo "Perhaps run the $install_or_upgrade script using 'sudo'." 1>&2
    exit 1
fi
if ! check_for_commands perl ; then
    echo "Perhaps run the SWAMP-in-a-Box \"set up\" scripts." 1>&2
    exit 1
fi
if ! perl -e 'use parent' ; then
    echo
    echo "Error: The 'parent' module for 'perl' is missing" 1>&2
    echo "Perhaps run the SWAMP-in-a-Box \"set up\" scripts." 1>&2
    exit 1
fi
if ! "$BINDIR"/swampinabox_do_pre_checks.bash \
        "$mode" \
        "$swamp_context" \
        "$version" \
        "$build" \
        "$rpms_dir"
then
    exit 1
fi

echo
echo "#####################################################################"
echo

if [ "$mode" = "-install" ] && [ "$swamp_context" != "-singleserver" ]; then

aws_dns=$(curl -s -m 1 http://169.254.169.254/latest/meta-data/public-hostname ||:)

if [ -n "${aws_dns}" ]; then
  export HOSTNAME="${aws_dns}"
fi

cat <<EOF
We are currently using the following for this host's DNS name:

    $HOSTNAME

This name must be accessible to users and have a properly configured
SSL certificate.

EOF
    printf "Use '%s' as this host's DNS name? [N/y] " "$HOSTNAME"
    read -r answer
    printf '\n'

    if [ "$answer" != "y" ]; then
        need_hostname=1
        while [ "$need_hostname" -eq 1 ]; do
            printf 'Enter the DNS name (hostname) to use: '
            read -r answer
            printf '\n'
            export HOSTNAME=$answer

            printf "Determining the IP address of '%s' ... " "$HOSTNAME"
            if ! perl \
                    -e 'use Socket; print inet_ntoa(inet_aton($ARGV[0])) . "\n";' \
                    "$HOSTNAME" \
                    2>&1
            then
                echo
                echo "Error: Failed to determine the IP address of '$HOSTNAME'" 1>&2
            else
                need_hostname=0
            fi
        done
    fi

elif [ "$mode" = "-upgrade" ]; then
    echo "Extracting DNS name from /var/www/swamp-web-server/.env"

    app_url="^[[:space:]]*APP_URL[[:space:]]*[=][[:space:]]*"
    protocol="http[s]\\?[:][/][/]"

    HOSTNAME=$(grep "${app_url}" /var/www/swamp-web-server/.env \
                | head -n 1 \
                | sed "s/${app_url}${protocol}\\([^/]*\\).*\$/\\1/")

    echo "Setting \$HOSTNAME to '$HOSTNAME'"
    export HOSTNAME

else
    echo "\$HOSTNAME is set to '$HOSTNAME'"
fi

echo
echo "#####################################################################"
echo

#
# NOTE: Do not remove existing password files if this is a "singleserver"
# install. The "singleserver" installer prompts for and saves the required
# passwords *before* invoking this script.
#
ask_for_password=$RUNTIME/sbin/create_mysql_root
prompt_for="Enter the password to use for"

if [ "$swamp_context" != "-singleserver" ]; then
    remove_db_password_files

    if [ "$mode" = "-install" ]; then
        "$ask_for_password" /etc/.mysql_root \
            --prompt="${prompt_for} the database's 'root' user: " \
            --confirm
        "$ask_for_password" /etc/.mysql_web \
            --prompt="${prompt_for} the database's web application user: "
        "$ask_for_password" /etc/.mysql_java \
            --prompt="${prompt_for} the database's SWAMP services user: "
        "$ask_for_password" /etc/.mysql_admin \
            --prompt="${prompt_for} the SWAMP's administrator account: " \
            --php-bcrypt
    elif [ "$mode" = "-upgrade" ]; then
        "$ask_for_password" /etc/.mysql_root \
            --prompt="${prompt_for} the database's 'root' user: " \
            --test
    fi
fi

echo
echo "#####################################################################"
echo
echo "### Stopping Services"
echo

#
# NOTE: Do not tell the 'docker' service to stop, because we want to respect
# the fact that the SWAMP might not "own" the installation.
#

tell_service                httpd        stop
tell_service --skip-missing swamp        stop    # might not be installed
tell_service --skip-missing swamp-condor stop    # might not be installed
tell_service --skip-missing mysql        stop    # might not be aliased yet
tell_service                libvirtd     stop

#
# The initial sub-scripts all need to succeed. If any of them fail, there
# will not be much of a system to salvage, and it would be better to retry
# the install or upgrade from the beginning.
#
set -o errexit

"$BINDIR"/swampinabox_do_setup.bash
"$BINDIR"/swampinabox_install_rpms.bash "$rpms_dir" "$version" "$build" "$mode"

case "$mode" in
    -install)
        "$RUNTIME"/sbin/swamp_init_empty_db --force
        "$RUNTIME"/sbin/swamp_init_db "$mode" "$swamp_context"

        echo
        echo "### Setting Initial Passwords"
        echo
        "$BINDIR"/swampinabox_patch_passwords.pl token

        #
        # Fix passwords containing spaces.
        # TODO baydemir: Incorporate this into the script above.
        #
        "$BINDIR"/runtime/sbin/swamp_copy_config \
            -i "/var/www/swamp-web-server/.env" \
            -o "/var/www/swamp-web-server/.env" \
            --no-space --quote-for-laravel-55
        ;;

    -upgrade)
        "$RUNTIME"/bin/swamp_backup_db --output-dir="."
        "$RUNTIME"/sbin/swamp_init_db "$mode" "$swamp_context"
        ;;
esac

set +o errexit

"$BINDIR"/configure_file_system.bash "$swamp_context"
"$BINDIR"/configure_htcondor.bash
"$BINDIR"/configure_httpd.bash
"$BINDIR"/configure_sudo_libvirt.bash

echo
echo "### Configuring SWAMP Hostname"
echo
/opt/swamp/bin/swamp_set_db_host        --hostname=localhost
/opt/swamp/bin/swamp_set_htcondor_host  --hostname=localhost
/opt/swamp/bin/swamp_set_web_host       --hostname="$HOSTNAME"

echo
echo "### Installing Tools"
echo

tell_service mysql restart
/opt/swamp/sbin/create_mysql_root_cnf /opt/swamp/sql/sql.cnf
"$BINDIR"/swamp_install_tools.bash "$swamp_context" "$version"
rm -f /opt/swamp/sql/sql.cnf
tell_service mysql stop

/opt/swamp/sbin/rebuild_tools_db "$swamp_context"

echo
echo "### Installing Platforms"
echo
"$BINDIR"/swamp_install_platforms.bash "$swamp_context" "$version"
/opt/swamp/sbin/rebuild_platforms_db

echo
echo "### Restarting Services"
echo

if [ -e /usr/lib/systemd/system/docker.service ]; then
    #
    # NOTE: We never told the 'docker' service to 'stop',
    # so we need only to ensure that the service is running.
    #
    tell_service docker start
fi

tell_service libvirtd     restart
tell_service mysql        restart
tell_service swamp-condor restart ; "$RUNTIME"/sbin/swamp_wait_for_htcondor
tell_service swamp        restart
tell_service httpd        restart

############################################################################

#
# Clean up and report the final disposition of the install/upgrade.
#
remove_db_password_files
trap '' ERR

"$RUNTIME"/bin/swamp_check_install --hostname="$HOSTNAME" --wait-for-condor
health_code=$?

if [ $encountered_error -ne 0 ]; then
    echo "Warning: There were unexpected errors during the $install_or_upgrade process." 1>&2
fi
if [ $health_code -ne 0 ]; then
    exit $health_code
fi
exit $encountered_error
