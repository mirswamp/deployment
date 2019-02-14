#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

#
# Do the set up tasks that are common to all SWAMP-in-a-Boxes and
# that can be done without internet access or input from the user.
#

echo ""
echo "### Setting Up This Host for SWAMP-in-a-Box"
echo ""

encountered_error=0
trap 'encountered_error=1 ; echo "Error (unexpected): $BASH_COMMAND" 1>&2' ERR
set -o errtrace

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$BINDIR/runtime/bin/swamp_utility.functions"
source "$BINDIR/swampinabox_install_util.functions"

############################################################################

#
# Ensure that we can refer to the system DB service as 'mysql'.
#
if [ -e /usr/lib/systemd/system/mariadb.service ]; then
    if [ ! -h /etc/systemd/system/mysql.service ]; then
        echo "Creating symlink from mysql.service to mariadb.service"
        rm -f /etc/systemd/system/mysql.service
        ln -s /usr/lib/systemd/system/mariadb.service /etc/systemd/system/mysql.service
    else
        echo "Found /etc/systemd/system/mysql.service"
    fi
fi

#
# Ensure that system services start up automatically after a system restart.
#
if [ -e /usr/lib/systemd/system/mariadb.service ]; then
    enable_service mariadb
fi
if [ -e /etc/rc.d/init.d/mysql ]; then
    enable_service mysql
fi
enable_service httpd
enable_service libvirtd

#
# Ensure that the 'mysql' user's shell is set appropriately.
#
if [[ ! ( $(getent passwd mysql) =~ :/bin/bash$ ) ]]; then
    echo "Setting the mysql user's shell to /bin/bash ..."
    chsh -s /bin/bash mysql
else
    echo "The mysql user's shell is /bin/bash"
fi

#
# Ensure that the SWAMP's "system user" exists.
#
create_user swa-daemon

#
# In 1.34, we switched to installing and using a "local" HTCondor instance
# in /opt/swamp. When upgrading, we will essentially shutdown the existing
# system-wide HTCondor instance, but otherwise leave the RPMs installed.
#
current_version=$(get_rpm_version swampinabox-backend)

if [[ "$current_version" =~ ^1[.](27|28|29|30|31|32|33)[.-] ]]; then
    echo "Stopping and disabling the system-wide HTCondor instance ..."
    #
    # None of these steps are required to succeed.
    #
    tell_services stop condor           || :
    disable_service condor              || :
    yum versionlock delete "*:condor-*" || :
    groupdel slotusers                  || :
fi

############################################################################

if [ $encountered_error -eq 0 ]; then
    echo "Finished setting up this host for SWAMP-in-a-Box"
else
    echo "Finished setting up this host for SWAMP-in-a-Box, but with errors" 1>&2
fi
exit $encountered_error
