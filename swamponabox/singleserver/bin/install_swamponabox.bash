#!/bin/bash
BINDIR=`dirname $0`
RELAYHOST="128.104.153.1"

. $BINDIR/../sbin/getargs.function

if [[ "$0" =~ "install_swamponabox" ]]; then
    getargs "-install $*"
else
    getargs "-upgrade $*"
fi

args_ok=$?
if [ $args_ok -ne 0 ]; then
    exit
fi

#
# Check that required "software" resources are available.
#

$BINDIR/../sbin/swamponabox_check_software.bash

if [ $? -ne 0 ]; then
    exit 1
fi

#
# Check for source code and perform the install.
#

echo ""
echo "############################################################"
echo "##### Checking for Source Files in Developer Directory #####"
echo "############################################################"
if [ ! -d $WORKSPACE/deployment/swamp ]; then
	echo "There is no deployment directory in which to build rpms"
	echo "Create a workspace in a developer's home directory such as /home/<user>/swamp"
	echo "Change to that directory and execute git_clone.bash"
	echo "Then execute $0"
	exit
else
	echo "Found deployment directory: $WORKSPACE/deployment/swamp"
fi

echo ""
echo "#############################"
echo "##### Stopping Services #####"
echo "#############################"
$BINDIR/../sbin/swamponabox_configure_services.bash
$BINDIR/../sbin/manage_services.bash stop

if [ "$MODE" == "-install" ]; then

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
	echo "########################################"
	echo "##### Installing Required Packages #####"
	echo "########################################"
	$BINDIR/../sbin/yum_install.bash

	echo ""
	echo "###############################################"
	echo "##### Installing and Configuring HTCondor #####"
	echo "###############################################"
	$BINDIR/../sbin/condor_install.bash

fi

echo ""
echo "######################################"
echo "##### Setting mysql User's Shell #####"
echo "######################################"
chsh -s /bin/bash mysql

echo ""
echo "###########################################"
echo "##### Setting Database Password Files #####"
echo "###########################################"
echo $DBPASSWORD | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_root -pass pass:swamp
chmod 400 /etc/.mysql_root
echo $DBPASSWORD | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_web -pass pass:swamp
chmod 400 /etc/.mysql_web
echo $DBPASSWORD | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_java -pass pass:swamp
chmod 400 /etc/.mysql_java
echo $SWAMPADMINPASSWORD | sudo openssl enc -aes-256-cbc -salt -out /etc/.mysql_admin -pass pass:swamp
chmod 400 /etc/.mysql_admin

echo ""
echo "#########################"
echo "##### Building RPMS #####"
echo "#########################"
$BINDIR/../sbin/swamponabox_build_rpms.bash singleserver $WORKSPACE $RELEASE_NUMBER $BUILD_NUMBER

echo ""
echo "###########################"
echo "##### Installing RPMS #####"
echo "###########################"
$BINDIR/../sbin/swamponabox_install_rpms.bash "$WORKSPACE/deployment/swamp" $RELEASE_NUMBER $BUILD_NUMBER $MODE

echo ""
echo "#######################################"
echo "##### Patching Database Passwords #####"
echo "#######################################"
$BINDIR/../sbin/swamponabox_patch_passwords.pl token

echo ""
echo "############################################"
echo "##### Removing Database Password Files #####"
echo "############################################"
rm -f /etc/.mysql_root
rm -f /etc/.mysql_web
rm -f /etc/.mysql_java
rm -f /etc/.mysql_admin

if [ "$MODE" == "-install" ]; then

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
	echo "#############################"
	echo "##### Configuring Email #####"
	echo "#############################"
	$BINDIR/../sbin/mail_configure.bash $RELAYHOST

fi

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
