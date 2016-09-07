#!/bin/bash
BINDIR=`dirname $0`

if [[ "$0" =~ "install_swampinabox" ]]; then
    MODE="-install"
else
    MODE="-upgrade"
fi

WORKSPACE="$BINDIR/../swampsrc"
read RELEASE_NUMBER BUILD_NUMBER < $BINDIR/version.txt

#
# Check that the available hardware resources are sufficient.
#

. $BINDIR/../sbin/swamponabox_check_cpu.function
. $BINDIR/../sbin/swamponabox_check_memory.function

check_cpu
cpu_ok=$?

check_memory
memory_ok=$?

if [ $cpu_ok -ne 0 -o $memory_ok -ne 0 ]; then
    echo "Warning: Did not find sufficient hardware resources for running SWAMP."
    echo -n "Continue with the install anyway? [N/y] "
    read ANSWER
    if [ "$ANSWER" != "y" ]; then
        echo "Exiting ..."
        exit
    fi
fi

#
# Check that required "software" resources are available.
#

$BINDIR/../sbin/swamponabox_check_software.bash

if [ $? -ne 0 ]; then
    exit 1
fi

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

        stty -echo
        echo -n "$PROMPT "
        read -r ANSWER
        echo
        stty echo

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

echo ""
echo "===================================="
echo "=== SWAMP-in-a-Box Configuration ==="
echo "===================================="
echo "Release number: $RELEASE_NUMBER"
echo "Build number: $BUILD_NUMBER"
# echo "Reply-to email address: $EMAIL"
# echo "Postfix relay host: $RELAYHOST"

echo ""
echo "#############################"
echo "##### Stopping Services #####"
echo "#############################"
$BINDIR/../sbin/manage_services.bash stop

echo ""
echo "##################################"
echo "##### Configuring /etc/hosts #####"
echo "##################################"
$BINDIR/../sbin/hosts_configure.bash

echo ""
echo "#############################"
echo "##### Configuring Clock #####"
echo "#############################"
$BINDIR/../sbin/clock_configure.bash

echo ""
echo "###############################################"
echo "##### Installing and Configuring HTCondor #####"
echo "###############################################"
$BINDIR/../sbin/condor_install.bash

echo ""
echo "######################################"
echo "##### Setting mysql User's Shell #####"
echo "######################################"
chsh -s /bin/bash mysql

echo ""
echo "###########################################"
echo "##### Setting Database Password Files #####"
echo "###########################################"
echo "$DBROOT" | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_root -pass pass:swamp
chmod 400 /etc/.mysql_root
echo "$DBWEB" | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_web -pass pass:swamp
chmod 400 /etc/.mysql_web
echo "$DBJAVA" | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_java -pass pass:swamp
chmod 400 /etc/.mysql_java
echo "$SWAMPADMIN" | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_admin -pass pass:swamp
chmod 400 /etc/.mysql_admin

echo ""
echo "###########################"
echo "##### Installing RPMS #####"
echo "###########################"
$BINDIR/../sbin/swamponabox_install_rpms.bash $WORKSPACE $RELEASE_NUMBER $BUILD_NUMBER $MODE

echo ""
echo "#######################################"
echo "##### Patching Database Passwords #####"
echo "#######################################"
$BINDIR/../sbin/swamponabox_patch_passwords.pl token

echo ""
echo "########################################"
echo "##### Configuring sudo and libvirt #####"
echo "########################################"
$BINDIR/../sbin/sudo_libvirt.bash

echo ""
echo "########################################"
echo "##### Configuring SWAMP Filesystem #####"
echo "########################################"
$BINDIR/../sbin/swamponabox_make_filesystem.bash

echo ""
echo "################################"
echo "##### Installing Platforms #####"
echo "################################"
$BINDIR/../sbin/swamp_install_platforms.bash

echo ""
echo "############################"
echo "##### Installing Tools #####"
echo "############################"
$BINDIR/../sbin/swamp_install_tools.bash

echo ""
echo "############################################"
echo "##### Removing Database Password Files #####"
echo "############################################"
rm -f /etc/.mysql_root
rm -f /etc/.mysql_web
rm -f /etc/.mysql_java
rm -f /etc/.mysql_admin

echo ""
echo "#############################"
echo "##### Configuring Email #####"
echo "#############################"
$BINDIR/../sbin/mail_configure.bash $RELAYHOST

echo ""
echo "###############################"
echo "##### Restarting Services #####"
echo "###############################"
$BINDIR/../sbin/manage_services.bash restart

echo ""
echo "##################################"
echo "##### Listing IPTABLES Rules #####"
echo "##################################"
iptables --list-rules

echo ""
echo "####################################"
echo "##### Installation Diagnostics #####"
echo "####################################"
echo "SELinux: `getenforce`"
echo ""
echo "================="
echo "=== Repo List ==="
echo "================="
yum repolist
echo ""
echo "=========================="
echo "=== Installed Packages ==="
echo "=========================="
yum list installed | egrep 'mariadb|php|swamp'
echo ""
echo "==========================================="
echo "=== Web Configuration: swamp-web-server ==="
echo "==========================================="
cat /var/www/swamp-web-server/.env | grep -v -i 'password[ ]*='
echo ""
echo "==============================="
echo "=== Web Configuration: html ==="
echo "==============================="
cat /var/www/html/scripts/config.js
echo ""
echo "============================="
echo "=== Backend Configuration ==="
echo "============================="
cat /opt/swamp/etc/swamp.conf | grep -v -i 'pass[ ]*='
echo ""
echo "====================="
echo "=== System Health ==="
echo "====================="
/opt/perl5/perls/perl-5.18.1/bin/perl $BINDIR/../health_scripts/swamphealth.pl -all

echo ""
echo "###############################################"
echo "##### SWAMP-in-a-Box Install Has Finished #####"
echo "###############################################"
echo ""
echo "SWAMP-in-a-Box should be available the following URL:"
echo "https://$HOSTNAME"
