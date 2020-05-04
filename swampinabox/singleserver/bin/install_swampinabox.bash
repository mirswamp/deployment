#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

#
# Install or upgrade SWAMP-in-a-Box on this host.
#

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "$0")" && pwd)

now=$(date +"%Y%m%d_%H%M%S")
relay_host=128.104.153.20

############################################################################

show_usage_and_exit() {
    echo "Usage: $0 <version number> [database password] [SWAMP administrator password]" 1>&2
    exit 1
}

get_args() {
    MODE=""
    VERSION_NUMBER=""
    BUILD_NUMBER=""
    DBPASSWORD=""
    SWAMPADMINPASSWORD=""

    for arg in "$@" ; do
        case "$arg" in
            -install)
                MODE=-install
                ;;
            -upgrade)
                MODE=-upgrade
                ;;
            -\?|-h|-help|--help)
                show_usage_and_exit
                ;;
            *)  if [ -z "$VERSION_NUMBER" ]; then
                    VERSION_NUMBER=$arg
                elif [ -z "$DBPASSWORD" ]; then
                    DBPASSWORD=$arg
                else
                    SWAMPADMINPASSWORD=$arg
                fi
                ;;
        esac
    done

    #
    # Set reasonable defaults for anything that was not specified.
    #
    if [ -z "$MODE" ]; then
        MODE=-install
    fi
    if [ -z "$VERSION_NUMBER" ] \
       && rpm -q --whatprovides swampinabox-backend 1>/dev/null 2>&1
    then
        VERSION_NUMBER=$(rpm -q --qf '%{VERSION}' swampinabox-backend)
    fi
    if [ -z "$BUILD_NUMBER" ]; then
        BUILD_NUMBER=$(date +"%Y%m%d%H%M%S").singleserver
    fi
    if [ -z "$DBPASSWORD" ]; then
        DBPASSWORD=swampinabox
    fi
    if [ -z "$SWAMPADMINPASSWORD" ]; then
        SWAMPADMINPASSWORD=swamp
    fi

    #
    # Check for errors.
    #
    if [ -z "$VERSION_NUMBER" ]; then
        echo "Error: Version number is required" 1>&2
        echo
        show_usage_and_exit
    fi
    if [[ ! ( "$VERSION_NUMBER" =~ ^[[:digit:]]+([.][[:digit:]]+).*$ ) ]]; then
        echo "Error: Version number is not well formed" 1>&2
        echo
        show_usage_and_exit
    fi

    #
    # Write out what we found.
    #
    echo "Version: $VERSION_NUMBER (build $BUILD_NUMBER)"
    echo "Mode: $MODE"
    echo "Database password: $DBPASSWORD"
    echo "SWAMP administrator password: $SWAMPADMINPASSWORD"
}

############################################################################

#
# Determine the install type, log file location, etc.
#
if [ -d "$BINDIR"/../log ]; then
    swamp_log_dir=$BINDIR/../log
else
    swamp_log_dir=.
fi

if [[ "$0" =~ install_swampinabox ]]; then
    get_args -install "$@" || exit 1
    swamp_log_file=$swamp_log_dir/install_swampinabox_$now.log
else
    get_args -upgrade "$@" || exit 1
    swamp_log_file=$swamp_log_dir/upgrade_swampinabox_$now.log
fi

WORKSPACE=$BINDIR/../../../..

#
# Check that the SWAMP's Git repositories have been checked out into the
# expected locations.
#
for repo in \
        db \
        deployment \
        proprietary \
        services \
        swamp-web-server \
        www-front-end \
        ; do
    if [ ! -d "$WORKSPACE/$repo" ]; then
        echo
        echo "Error: Missing Git repository: $WORKSPACE/$repo" 1>&2
        exit 1
    fi
done

#
# Ensure that we are running as 'root', because we will be creating the
# DB password files here, before running the core install/upgrade script.
#
if [ "$(whoami)" != "root" ]; then
    echo
    echo "Error: This script must be run as 'root'. Perhaps use 'sudo'." 1>&2
    exit 1
fi

#
# Do the set up tasks that the "distribution" install requires the user to
# do separately from the main install and the set up tasks that are specific
# to a "singleserver" install.
#
set -o pipefail
if ! "$BINDIR"/../sbin/swampinabox_do_singleserver_setup.bash \
        "$MODE" \
        "$relay_host" \
    2>&1 | tee -a "$swamp_log_dir/singleserver_setup_$now.log"
then
    exit 1
fi

#
# Build the SWAMP-in-a-Box RPMs.
#
set -o pipefail
if ! "$BINDIR"/../sbin/swampinabox_build_rpms.bash \
        "singleserver" \
        "$WORKSPACE" \
        "$VERSION_NUMBER" \
        "$BUILD_NUMBER" \
    2>&1 | tee -a "$swamp_log_dir/singleserver_build_rpms_$now.log"
then
    exit 1
fi

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

#
# Save encrypted DB passwords into files for use by other scripts.
#
echo
echo "### Saving DB Password Files"
echo
remove_db_password_files

save_password_cmd=$BINDIR/../sbin/runtime/sbin/create_mysql_root

printf '%s\n' "$DBPASSWORD" \
    | "$save_password_cmd" /etc/.mysql_root  --prompt=""
printf '%s\n' "$DBPASSWORD" \
    | "$save_password_cmd" /etc/.mysql_web   --prompt=""
printf '%s\n' "$DBPASSWORD" \
    | "$save_password_cmd" /etc/.mysql_java  --prompt=""
printf '%s\n' "$SWAMPADMINPASSWORD" \
    | "$save_password_cmd" /etc/.mysql_admin --prompt="" --php-bcrpt

#
# Run the core of the install/upgrade process.
#
set -o pipefail
"$BINDIR"/../sbin/swampinabox_do_install.bash \
        "$MODE" \
        "-singleserver" \
        "$VERSION_NUMBER" \
        "$BUILD_NUMBER" \
        "$WORKSPACE/deployment/swamp/RPMS" \
    2>&1 | tee -a "$swamp_log_file"
main_install_exit_code=$?

#
# Copy the log file to a more permanent location, if we can.
#
if [ -d /opt/swamp/log ]; then
    cp "$swamp_log_file" /opt/swamp/log/.
fi
exit $main_install_exit_code
