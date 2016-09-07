#!/bin/bash
BINDIR=`dirname $0`

yum -y install condor-all

mkdir -p /slots
chown condor:condor /slots
cp -r $BINDIR/../swamponabox_installer/config.d /etc/condor

hostip=`$BINDIR/../sbin/find_ip_address.pl $HOSTNAME`
if [ -n "$hostip" ]; then
    echo "Patching swamponabox_network.conf for Condor using ip: $hostip"
    sed -i "s/HOSTIP/$hostip/" /etc/condor/config.d/swamponabox_network.conf
fi

domain="$HOSTNAME"
if [ -n "$domain" ]; then
    echo "Patching swamponabox_jobcontrol.conf for Condor using domain: $domain"
    sed -i "s/PATCH_DEFAULT_DOMAIN_NAME//" /etc/condor/config.d/swamponabox_jobcontrol.conf
    sed -i "s/PATCH_UID_DOMAIN/$domain/" /etc/condor/config.d/swamponabox_jobcontrol.conf
    sed -i "s/PATCH_ALLOW_WRITE/$domain/" /etc/condor/config.d/swamponabox_jobcontrol.conf
fi

chkconfig condor on
service condor start
