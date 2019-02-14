#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

echo
echo "### Erasing most traces of SWAMP-in-a-Box"
echo

#
# Intended for internal development. Dependencies installed by the "set up"
# scripts are not removed, except for HTCondor. Database data files are also
# not removed.
#

############################################################################

this_host=$(hostname)

if [[ ! ( "$this_host" =~ -dt-(09|10|11|12)[.] ) ]]; then
    echo "Error: Not a supported host: $this_host" 1>&2
    exit 1
fi

if [ "$(whoami)" != "root" ]; then
    echo "Error: This utility must be run as 'root'. Perhaps use 'sudo'." 1>&2
    exit 1
fi

set -x

service httpd        stop
service swamp        stop ; chkconfig swamp off
service swamp-condor stop ; chkconfig swamp-condor off
service mysql        stop

yum erase -y \
    'condor*' \
    swamp-rt-java swamp-rt-perl \
    swamp-web-server \
    swampinabox-backend swamponabox-backend

service libvirtd start
virsh net-destroy  swampinabox
virsh net-undefine swampinabox
virsh net-destroy  swamponabox
virsh net-undefine swamponabox

service libvirtd  stop
service iptables  restart
service firewalld restart

chsh -s /bin/sh mysql
userdel -r condor
userdel -r swa-daemon
groupdel condor
groupdel slotusers
groupdel swa-results

rm -f  /etc/condor/config.d/swampinabox*
rm -f  /etc/condor/config.d/swamponabox*
rm -f  /etc/init.d/swamp-condor
rm -f  /etc/sudoers.d/10_slotusers
rm -f  /etc/sudoers.d/10_swamp_sudo_config
rm -f  /etc/systemd/system/mysql.service
rm -f  /etc/systemd/system/swamp-condor.service
rm -rf /opt/swamp
rm -rf /slots
rm -f  /usr/libexec/qemu-kvm-us
rm -rf /var/www/html/*
rm -rf /var/www/html/.[A-Za-z]*
rm -rf /var/www/swamp-web-server

#
# Ensure that we get the exit code from 'grep' below.
#
set +o pipefail

if ! mount | grep -E '[[:space:]](/swamp)[[:space:]/]'
then
    rm -rf /swamp
fi

find /etc -regextype posix-extended \
          -regex '/etc/httpd/conf[.]d/ssl[.]conf[.][[:digit:]]{14}' \
          -print -exec rm -f '{}' ';'

find /etc -regextype posix-extended \
          -regex '/etc/php[.]ini[.][[:digit:]]{14}' \
          -print -exec rm -f '{}' ';'

for ext in "" .rpmnew .rpmsave ; do
    rm -f /etc/httpd/conf/httpd.conf"$ext"
    rm -f /etc/httpd/conf.d/ssl.conf"$ext"
    rm -f /etc/php.ini"$ext"
    rm -f /etc/postfix/main.cf"$ext"
done

yum versionlock delete '*:condor-*'
yum reinstall -y httpd mod_ssl php-common postfix

set +x

############################################################################

echo
echo "Finished erasing most traces of SWAMP-in-a-Box"
