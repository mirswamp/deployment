#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname "$0"`

WORKSPACE="$1"
RELEASE_NUMBER="$2"
BUILD_NUMBER="$3"
RELAYHOST="$4"
MODE="$5"
SWAMP_LOGFILE="$6"
SWAMP_CONTEXT="$7"
SHORT_RELEASE_NUMBER="$8"

. $BINDIR/swampinabox_install_util.functions

#
# Sections guarded by a "$MODE" check should need to be executed only once,
# when SWAMP-in-a-Box is initially installed. However, ideally, they should
# be safe to execute multiple times.
#

echo ""
echo "########################################"
echo "##### SWAMP-in-a-Box Configuration #####"
echo "########################################"
echo "Release number: $RELEASE_NUMBER"
echo "Build number: $BUILD_NUMBER"
echo "Hostname: $HOSTNAME"
echo "Postfix relay host: $RELAYHOST"

if [ -x $BINDIR/yum_install.bash ]; then
    echo ""
    echo "########################################"
    echo "##### Installing Required Packages #####"
    echo "########################################"
    $BINDIR/yum_install.bash
fi

echo ""
echo "#############################"
echo "##### Stopping Services #####"
echo "#############################"
if [ -x $BINDIR/swampinabox_configure_services.bash ]; then
    $BINDIR/swampinabox_configure_services.bash
fi
$BINDIR/manage_services.bash stop

echo ""
echo "##################################"
echo "##### Configuring /etc/hosts #####"
echo "##################################"
$BINDIR/configure_hosts.bash

if [ -x $BINDIR/configure_clock.bash ]; then
    echo ""
    echo "#############################"
    echo "##### Configuring Clock #####"
    echo "#############################"
    $BINDIR/configure_clock.bash "$MODE" "$SWAMP_CONTEXT"
fi

echo ""
echo "################################"
echo "##### Configuring HTCondor #####"
echo "################################"
$BINDIR/condor_install.bash

echo ""
echo "######################################"
echo "##### Setting mysql User's Shell #####"
echo "######################################"
chsh -s /bin/bash mysql

#
# The "workspace" used by the RPM install script ($RPMWORKSPACE) depends
# on whether we built the RPMs as part of the install.
#
if [ -x $BINDIR/swampinabox_build_rpms.bash ]; then
    echo ""
    echo "#########################"
    echo "##### Building RPMS #####"
    echo "#########################"
    $BINDIR/swampinabox_build_rpms.bash singleserver "$WORKSPACE" "$RELEASE_NUMBER" "$BUILD_NUMBER" || abort_install
    RPMWORKSPACE="$WORKSPACE/deployment/swamp"
else
    RPMWORKSPACE="$WORKSPACE"
fi

if [ -x $BINDIR/swampinabox_clean_rpms.bash ]; then
    echo ""
    echo "##########################################"
    echo "##### Cleaning RPM Build By-Products #####"
    echo "##########################################"
    $BINDIR/swampinabox_clean_rpms.bash "$WORKSPACE"
fi

echo ""
echo "###########################"
echo "##### Installing RPMS #####"
echo "###########################"
$BINDIR/swampinabox_install_rpms.bash "$RPMWORKSPACE" "$RELEASE_NUMBER" "$BUILD_NUMBER" "$MODE" || abort_install

echo ""
echo "##########################################"
echo "##### Performing Database Operations #####"
echo "##########################################"
$BINDIR//swampinabox_install_database.bash "$MODE" "$SWAMP_CONTEXT" || abort_install

echo ""
echo "#######################################################"
echo "##### Setting Hostname in Configuration Locations #####"
echo "#######################################################"
/opt/swamp/bin/swamp_set_db_host "localhost"
/opt/swamp/bin/swamp_set_htcondor_host "localhost.localdomain"
/opt/swamp/bin/swamp_set_web_host "$HOSTNAME"

if [ "$MODE" == "-install" ]; then
    echo ""
    echo "#######################################"
    echo "##### Patching Database Passwords #####"
    echo "#######################################"
    $BINDIR/swampinabox_patch_passwords.pl token

    echo ""
    echo "#############################"
    echo "##### Configuring Email #####"
    echo "#############################"
    $BINDIR/configure_mail.bash $RELAYHOST
fi

echo ""
echo "########################################"
echo "##### Configuring SWAMP Filesystem #####"
echo "########################################"
$BINDIR/swampinabox_make_filesystem.bash

if [ -x $BINDIR/swamp_install_platforms.bash ]; then
    echo ""
    echo "################################"
    echo "##### Installing Platforms #####"
    echo "################################"
    $BINDIR/swamp_install_platforms.bash "$SHORT_RELEASE_NUMBER"
fi

if [ -x $BINDIR/swamp_install_tools.bash ]; then
    echo ""
    echo "############################"
    echo "##### Installing Tools #####"
    echo "############################"
    $BINDIR/swamp_install_tools.bash "$SHORT_RELEASE_NUMBER"
fi

echo ""
echo "########################################"
echo "##### Configuring sudo and libvirt #####"
echo "########################################"
$BINDIR/sudo_libvirt.bash

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
coproc services_fds { $BINDIR/manage_services.bash restart 2>&1; }

exec {services_fd}<&${services_fds[0]}

success=0
while [ $success -eq 0 ]; do
    read -r -d '' -n 1 -t 1 -u ${services_fd}
    success=$?
    echo -n "$REPLY"
    if [ $success -ne 0 -a ! -z "${services_fds[0]}" ]; then
        # Keep waiting as long as manage_services.bash is alive.
        success=0
    fi
done

echo ""
echo "####################################"
echo "##### Installation Diagnostics #####"
echo "####################################"
echo "SELinux: `getenforce`"
echo ""
echo "==========================="
echo "=== yum Repository List ==="
echo "==========================="
yum repolist
echo ""
echo "=========================="
echo "=== Installed Packages ==="
echo "=========================="
yum list installed | egrep 'mariadb|php|swamp'
echo""
echo "======================"
echo "=== IPTABLES Rules ==="
echo "======================"
iptables --list-rules
echo ""
echo "==========================================="
echo "=== Web Configuration: swamp-web-server ==="
echo "==========================================="
cat /var/www/swamp-web-server/.env | grep -v -i 'password[ ]*='
echo ""
echo "==============================="
echo "=== Web Configuration: html ==="
echo "==============================="
cat /var/www/html/config/config.json
echo ""
echo "============================="
echo "=== Backend Configuration ==="
echo "============================="
cat /opt/swamp/etc/swamp.conf | grep -v -i 'pass[ ]*='
# echo ""
# echo "====================="
# echo "=== System Health ==="
# echo "====================="
# /opt/perl5/perls/perl-5.18.1/bin/perl $BINDIR/../health_scripts/swamphealth.pl -all

echo ""
echo "############################################"
echo "##### Removing Database Password Files #####"
echo "############################################"
remove_db_password_files

echo ""
echo "###############################################"
echo "##### SWAMP-in-a-Box Install Has Finished #####"
echo "###############################################"
echo ""
echo "Output from this install has been saved to:"
echo "$SWAMP_LOGFILE"
echo ""
echo "SWAMP-in-a-Box should be available at:"
echo "https://$HOSTNAME"
