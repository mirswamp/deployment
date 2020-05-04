#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

echo
echo "### Erasing SWAMP-in-a-Box"
echo

############################################################################

if [[ ! ( "$(hostname)" =~ -dt-(09)[.] ) ]]
then
    echo "Error: Not a supported host" 1>&2
    exit 1
fi

if [ "$(whoami)" != "root" ]
then
    echo "Error: This utility must be run as 'root'. Perhaps use 'sudo'." 1>&2
    exit 1
fi

set -x

service libvirtd start
virsh net-destroy  swampinabox
virsh net-undefine swampinabox
virsh net-destroy  swamponabox
virsh net-undefine swamponabox

for svc in condor docker httpd libvirtd swamp swamp-condor mysql
do
    service "$svc" stop
    chkconfig "$svc" off
done

service iptables  restart
service firewalld restart

yum versionlock delete '*:condor-*'

yum erase -y \
    swamp-rt-java swamp-rt-perl \
    swamp-web-server \
    swampinabox-backend swamponabox-backend \
    \
    'condor*' \
    containerd.io 'docker-*' libvirt 'libvirt-*' \
    mariadb mariadb-server mariadb-libs \
    MariaDB-client MariaDB-server MariaDB-shared \
    httpd httpd-tools mod_ssl \
    php 'php-*' libzip5 oniguruma5 \
    \
    epel-release remi-release \
    yum-utils yum-plugin-versionlock

rm -f \
    /etc/yum.repos.d/docker-ce.repo \
    /etc/yum.repos.d/epel-*.repo.rpmsave \
    /etc/yum.repos.d/remi-*.repo.rpmsave

chsh -s /bin/sh mysql
userdel -r condor
userdel -r swa-daemon
groupdel condor
groupdel slotusers
groupdel swa-results

rm -f  /etc/condor/config.d/swampinabox*
rm -f  /etc/condor/config.d/swamponabox*
rm -f  /etc/httpd/conf/httpd.conf.2*
rm -f  /etc/httpd/conf/httpd.conf.rpm*
rm -f  /etc/httpd/conf.d/ssl.conf.2*
rm -f  /etc/httpd/conf.d/ssl.conf.rpm*
rm -f  /etc/httpd/conf.d/swampinabox.conf
rm -f  /etc/init.d/swamp-condor
rm -f  /etc/php.ini.2*
rm -f  /etc/php.ini.rpm*
rm -f  /etc/postfix/main.cf.2*
rm -f  /etc/postfix/main.cf.rpm*
rm -f  /etc/sudoers.d/10_slotusers
rm -f  /etc/sudoers.d/10_swamp_sudo_config
rm -f  /etc/systemd/system/mysql.service
rm -f  /etc/systemd/system/swamp-condor.service
rm -rf /opt/containerd
rm -rf /opt/swamp
rm -rf /slots
rm -f  /usr/libexec/qemu-kvm-us
rm -rf /var/lib/docker
rm -rf /var/lib/mysql
rm -rf /var/www/html/*
rm -rf /var/www/html/.[A-Za-z]*
rm -rf /var/www/swamp-web-server

if ! mount | grep -E '[[:space:]](/swamp)[[:space:]/]'
then
    rm -rf /swamp
fi

set +x

printf '\nFinished\n'
