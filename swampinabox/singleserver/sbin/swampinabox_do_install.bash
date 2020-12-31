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

# run a pre-check, but not for a docker build
if [ "$swamp_context" = "-docker" ]
then
    echo
    echo "Skipping pre-checks in a docker build"
    echo
else
    if ! "$BINDIR"/swampinabox_do_pre_checks.bash \
            "$mode" \
            "$swamp_context" \
            "$version" \
            "$build" \
            "$rpms_dir"
    then
        exit 1
    fi
fi

echo
echo "#####################################################################"
echo

# get the hostname sorted
#
# in a Docker build, set the hostname to `localhost`
if [ "$swamp_context" = "-docker" ]
then
    export HOSTNAME=localhost
    echo
    echo For a docker build, setting the hostname to $HOSTNAME
    echo

# in a distribution install, get the hostname and prompt the user to accept or change
elif [ "$mode" = "-install" ] && [ "$swamp_context" = "-distribution" ]
then
    # get the right hostname for an AWS install
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

# For an upgrade, use the established hostname
elif [ "$mode" = "-upgrade" ]
then
    echo "Extracting DNS name from /var/www/swamp-web-server/.env"

    app_url="^[[:space:]]*APP_URL[[:space:]]*[=][[:space:]]*"
    protocol="http[s]\\?[:][/][/]"

    HOSTNAME=$(grep "${app_url}" /var/www/swamp-web-server/.env \
                | head -n 1 \
                | sed "s/${app_url}${protocol}\\([^/]*\\).*\$/\\1/")

    echo "Setting \$HOSTNAME to '$HOSTNAME'"
    export HOSTNAME

# in any other case just use the existing hostname
else
    echo "\$HOSTNAME is set to '$HOSTNAME'"
fi

echo
echo "#####################################################################"
echo
# Set passwords needed for the install/upgrade

if [ "$swamp_context" = "-docker" ]
then
    echo "### Using passwords copied via docker build"
    echo
else
    ask_for_password=$RUNTIME/sbin/create_mysql_root
    prompt_for="Enter the password to use for"

    # NOTE: Do not remove existing password files if this is a "singleserver"
    # or "docker" install. The "singleserver" installer prompts for and saves the required
    # passwords *before* invoking this script. The Dockerfile copies in the password files.
    if [ "$swamp_context" = "-distribution" ]; then
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
fi

# Stop services, except in a docker build, in which no services will be running
if [ "$swamp_context" != "-docker" ]
then
    echo
    echo "#####################################################################"
    echo
    echo "### Stopping Services"
    echo
    # NOTE: Do not tell the 'docker' service to stop, because we want to respect
    # the fact that the SWAMP might not "own" the installation.
    tell_service                httpd        stop
    tell_service --skip-missing swamp        stop    # might not be installed
    tell_service --skip-missing swamp-condor stop    # might not be installed
    tell_service --skip-missing mysql        stop    # might not be aliased yet
    tell_service                libvirtd     stop
fi

#
# The initial sub-scripts all need to succeed. If any of them fail, there
# will not be much of a system to salvage, and it would be better to retry
# the install or upgrade from the beginning.
#
set -o errexit

"$BINDIR"/swampinabox_do_setup.bash "$swamp_context"
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
"$BINDIR"/configure_htcondor.bash "$swamp_context"
"$BINDIR"/configure_httpd.bash
# Do not configure sudo/libvirt in a docker build
if [ "$swamp_context" != "-docker" ]
then
    "$BINDIR"/configure_sudo_libvirt.bash
fi

echo
echo "### Configuring SWAMP Hostname"
echo
/opt/swamp/bin/swamp_set_db_host        --hostname=localhost
/opt/swamp/bin/swamp_set_htcondor_host  --hostname=localhost
/opt/swamp/bin/swamp_set_web_host       --hostname="$HOSTNAME"

# Install tools and platforms:
if [ "$swamp_context" = "-docker" ]
then
    echo
    echo "### Installing Tools and Platforms"
    echo

    # need mysql to query and update database records
    tell_service mysql restart

    # make the config file so mysql commands can run without user entering password
    /opt/swamp/sbin/create_mysql_root_cnf /opt/swamp/sql/sql.cnf

    # run script to update the tools in the filesystem
    # needs access to the database to get file paths for add on tools (not relevant for new install)
    "$BINDIR"/swamp_install_tools.bash "$swamp_context" "$version"

    echo
    echo "The docker image for Ubuntu 16.04 must be available via DockerHub or loaded manually"
    echo

    # run script to update the platforms in the filesystem (mostly does nothing for a new install)
    # does not need access to the database.
    "$BINDIR"/swamp_install_platforms.bash "$swamp_context" "$version"

    echo "updating database records for tools and platforms"

    # run script to update tool and platform records in the database
    "$BINDIR"/swamp_install_platform_and_tool_db_records.bash "$swamp_context"

    # remove the config file for mysql commands
    rm -f /opt/swamp/sql/sql.cnf

    # stop the mysql service
    tell_service mysql stop
else
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
fi

############################################################################

#
# Clean up and report the final disposition of the install/upgrade.
#
remove_db_password_files
trap '' ERR

# Check the install, but not for a docker build
if [ "$swamp_context" != "-docker" ]
then
    "$RUNTIME"/bin/swamp_check_install --hostname="$HOSTNAME" --wait-for-condor
    health_code=$?
fi

if [ $encountered_error -ne 0 ]; then
    echo "Warning: There were unexpected errors during the $install_or_upgrade process." 1>&2
fi
# Report health codes, but not for a docker build
if [ "$swamp_context" != "-docker" ]
then
    if [ $health_code -ne 0 ]; then
        exit $health_code
    fi
fi

if [ "$swamp_context" = "-docker" ]
then
    echo
    echo "finished installing SiB in a docker container"
    echo
fi

exit $encountered_error