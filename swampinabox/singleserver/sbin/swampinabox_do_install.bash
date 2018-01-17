#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Install SWAMP-in-a-Box on the current host.
#

encountered_error=0
trap 'encountered_error=1; echo "Error: $0: $BASH_COMMAND" 1>&2' ERR
set -o errtrace

BINDIR="$(dirname "$0")"
WORKSPACE="$1"
RELEASE_NUMBER="$2"
BUILD_NUMBER="$3"
RELAYHOST="$4"
MODE="$5"
SWAMP_LOGFILE="$6"
SWAMP_CONTEXT="$7"
SHORT_RELEASE_NUMBER="$8"
ERROR_LOGFILE="$9"

. "$BINDIR/swampinabox_install_util.functions"

############################################################################

echo "Starting main SWAMP-in-a-Box install script: $0 $*"
echo ""
echo "Release number: $RELEASE_NUMBER ($SHORT_RELEASE_NUMBER)"
echo "Build number: $BUILD_NUMBER"
echo "Hostname: $HOSTNAME"
echo "Postfix relay host: $RELAYHOST"

echo ""
echo "#############################"
echo "##### Stopping Services #####"
echo "#############################"
"$BINDIR/manage_services.bash" stop

echo ""
echo "##################################"
echo "##### Configuring /etc/hosts #####"
echo "##################################"
"$BINDIR/configure_hosts.bash"

echo ""
echo "#############################"
echo "##### Configuring Clock #####"
echo "#############################"
"$BINDIR/configure_clock.bash" "$SWAMP_CONTEXT"

echo ""
echo "######################################"
echo "##### Configuring Apache (httpd) #####"
echo "######################################"
"$BINDIR/configure_httpd.bash"

echo ""
echo "################################"
echo "##### Configuring HTCondor #####"
echo "################################"
"$BINDIR/configure_htcondor.bash"

echo ""
echo "######################################"
echo "##### Setting mysql User's Shell #####"
echo "######################################"
if [[ ! ( $(getent passwd mysql) =~ :/bin/bash$ ) ]]; then
    chsh -s /bin/bash mysql
fi

#
# The "workspace" used by the RPM install script ($RPMWORKSPACE) depends
# on whether we built the RPMs as part of the install.
#
if [ -x "$BINDIR/swampinabox_build_rpms.bash" ]; then
    echo ""
    echo "#########################"
    echo "##### Building RPMS #####"
    echo "#########################"
    "$BINDIR/swampinabox_build_rpms.bash" "singleserver" "$WORKSPACE" "$RELEASE_NUMBER" "$BUILD_NUMBER" || abort_install
    RPMWORKSPACE="$WORKSPACE/deployment/swamp"
else
    RPMWORKSPACE="$WORKSPACE"
fi

echo ""
echo "###########################"
echo "##### Installing RPMS #####"
echo "###########################"
if ! "$BINDIR/swampinabox_install_rpms.bash" "$RPMWORKSPACE" "$RELEASE_NUMBER" "$BUILD_NUMBER" "$MODE" ; then
    encountered_error=1
    echo "Error: $0: Failed to install and/or configure SWAMP-in-a-Box RPMs" 1>&2

    rpms_with_wrong_version=$(check_rpm_versions "${RELEASE_NUMBER}-${BUILD_NUMBER}" swamp-rt-perl swampinabox-backend swamp-web-server)

    if [ ! -z "$rpms_with_wrong_version" ]; then
        abort_install
    else
        echo "Warning: $0: Continuing, correct versions of RPMs appear to be installed" 1>&2
    fi
fi

echo ""
echo "###############################################################"
echo "##### Installing Database Tables, Procedures, and Records #####"
echo "###############################################################"
if ! "$BINDIR/swampinabox_install_database.bash" "$MODE" "$SWAMP_CONTEXT" ; then
    encountered_error=1
    echo "Error: $0: Failed to install SWAMP database tables, procedures, and records" 1>&2
    abort_install
fi

echo ""
echo "#######################################################"
echo "##### Setting Hostname in the SWAMP Configuration #####"
echo "#######################################################"
/opt/swamp/bin/swamp_set_db_host        "localhost"
/opt/swamp/bin/swamp_set_htcondor_host  "localhost.localdomain"
/opt/swamp/bin/swamp_set_web_host       "$HOSTNAME"

if [ "$MODE" == "-install" ]; then
    echo ""
    echo "#######################################"
    echo "##### Patching Database Passwords #####"
    echo "#######################################"
    "$BINDIR/swampinabox_patch_passwords.pl" token

    echo ""
    echo "#############################"
    echo "##### Configuring Email #####"
    echo "#############################"
    "$BINDIR/configure_mail.bash" "$RELAYHOST"
fi

echo ""
echo "########################################"
echo "##### Configuring SWAMP Filesystem #####"
echo "########################################"
"$BINDIR/swampinabox_make_filesystem.bash"

echo ""
echo "################################"
echo "##### Installing Platforms #####"
echo "################################"
"$BINDIR/swamp_install_platforms.bash" "$SWAMP_CONTEXT" "$SHORT_RELEASE_NUMBER"

echo ""
echo "############################"
echo "##### Installing Tools #####"
echo "############################"
"$BINDIR/swamp_install_tools.bash" "$SWAMP_CONTEXT" "$SHORT_RELEASE_NUMBER"

echo ""
echo "########################################"
echo "##### Configuring sudo and libvirt #####"
echo "########################################"
"$BINDIR/configure_sudo_libvirt.bash"

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
    if [ $success -ne 0 -a ! -z "${services_fds[0]}" ]; then
        # Keep waiting as long as manage_services.bash is alive.
        success=0
    fi
done

#
# Clean up and report the final disposition of the install/upgrade.
#
remove_db_password_files

if [ $encountered_error -eq 0 ]; then
    echo ""
    echo "The install process has completed."
else
    echo ""
    echo "Warning: The install process has completed, but with errors." 1>&2
fi

exit $encountered_error
