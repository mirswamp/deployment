#!/bin/bash
BINDIR=`dirname $0`

# uses WORKSPACE, RELEASE_NUMBER, BUILD_NUMBER, MODE
WORKSPACE="$1"
RELEASE_NUMBER="$2"
BUILD_NUMBER="$3"
MODE="$4"

if [ "$MODE" == "-install" ]; then
	echo "Install RPMS"
else
	echo "Upgrade RPMS"
fi
echo ""
echo "WORKSPACE: $WORKSPACE"
echo "RELEASE_NUMBER: $RELEASE_NUMBER"
echo "BUILD_NUMBER: $BUILD_NUMBER"
echo "MODE: $MODE"

#
# Determine httpd.conf file to use.
#

httpd_ver=$(httpd -v | grep -i 'Server version' | head -n 1 | awk '{ print substr($0, match($0, /[[:digit:]]+.[[:digit:]]+/), RLENGTH); }')

echo ""
echo "Detected httpd version: ${httpd_ver}"

if [ ! -e $BINDIR/../swamponabox_web_config/httpd-${httpd_ver}.conf ]; then
    echo "Error: Cannot find source file for patching httpd.conf."
fi

echo ""
echo "Stopping services"
service mysql stop
service httpd stop
service condor stop

if [ "$MODE" == "-install" ]; then
	echo ""
	echo "Removing SWAMP RPMs"
	yum erase -y \
		swamp-rt-java.noarch \
		swamp-rt-perl.noarch \
		swamp-web-server.noarch \
		swamponabox-backend.noarch
fi

echo ""
echo "Installing SWAMP runtime components"
yum install -y $WORKSPACE/RPMS/swamp-rt-java-${RELEASE_NUMBER}-${BUILD_NUMBER}.noarch.rpm
yum install -y $WORKSPACE/RPMS/swamp-rt-perl-${RELEASE_NUMBER}-${BUILD_NUMBER}.noarch.rpm

echo ""
echo "Installing SWAMP web server"
yum install -y $WORKSPACE/RPMS/swamp-web-server-${RELEASE_NUMBER}-${BUILD_NUMBER}.noarch.rpm

echo ""
echo "Installing SWAMP backend"
yum install -y $WORKSPACE/RPMS/swamponabox-backend-${RELEASE_NUMBER}-${BUILD_NUMBER}.noarch.rpm

echo "Patching swamp.conf"
sed -i "s/HOSTNAME/$HOSTNAME/g" /opt/swamp/etc/swamp.conf
chgrp mysql /opt/swamp/etc/swamp.conf
chmod 440 /opt/swamp/etc/swamp.conf

echo ""
echo "Configuring web server"
if [ ! -h /var/www/html/swamp-web-server ]; then
	ln -s /var/www/swamp-web-server /var/www/html/swamp-web-server
fi

echo "Patching web server"
cat /var/www/swamp-web-server/env.swamponabox | sed -e "s/SED_HOSTNAME/$HOSTNAME/" | sed -e "s/SED_ENVIRONMENT/SWAMP-in-a-Box/" > /var/www/swamp-web-server/.env
chown apache:apache /var/www/swamp-web-server/.env
chmod 400 /var/www/swamp-web-server/.env

echo "Setting Laravel application key"
(cd /var/www/swamp-web-server ; php artisan key:generate --quiet)

echo "Patching html scripts"
cat /var/www/html/scripts/config/config.js.swamponabox | sed -e "s/SED_HOSTNAME/$HOSTNAME/" > /var/www/html/scripts/config/config.js
chown apache:apache /var/www/html/scripts/config.js
chmod 644 /var/www/html/scripts/config.js

echo "Patching httpd"
diff -wu /etc/httpd/conf/httpd.conf $BINDIR/../swamponabox_web_config/httpd-${httpd_ver}.conf | patch /etc/httpd/conf/httpd.conf

if [ "$MODE" == "-install" ]; then
    echo "Patching php.ini"
    $BINDIR/../sbin/swamponabox_patch_php_ini.pl /etc/php.ini

    patch_php_ok=$?
    if [ $patch_php_ok -ne 0 ]; then
        echo "Warning: Failed to patch php.ini file."
        echo "Warning: Uploading large packages to SWAMP might fail."
    fi
fi

if [ -f /etc/sysconfig/iptables ]; then
	echo "Patching iptables"
	diff -wu /etc/sysconfig/iptables $BINDIR/../swamponabox_web_config/iptables | patch /etc/sysconfig/iptables
else
	install -m 600 -o root -g root $BINDIR/../swamponabox_web_config/iptables /etc/sysconfig/iptables
fi
service iptables restart
