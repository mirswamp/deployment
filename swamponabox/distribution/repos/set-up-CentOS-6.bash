#!/usr/bin/env bash
BINDIR=`dirname "$0"`
SCRIPT_NAME=`basename "$0"`

. "$BINDIR"/set-up-common.functions

"$BINDIR"/set-up-common-pre.bash "$SCRIPT_NAME" || exit 1

echo ""
echo "########################################"
echo "##### Configuring yum Repositories #####"
echo "########################################"

echo ""
echo "================"
echo "=== HTCondor ==="
echo "================"

echo "Copying htcondor-stable-rhel6.repo to /etc/yum.repos.d"
cp "$BINDIR"/htcondor-stable-rhel6.repo /etc/yum.repos.d

echo "Importing GPG key"
rpm --import http://research.cs.wisc.edu/htcondor/yum/RPM-GPG-KEY-HTCondor

echo ""
echo "==============="
echo "=== MariaDB ==="
echo "==============="

echo "Copying MariaDB55.repo to /etc/yum/repos.d"
cp "$BINDIR"/MariaDB55.repo /etc/yum.repos.d

echo "Importing GPG key"
rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB

echo""
echo "==============="
echo "=== PHP 7.0 ==="
echo "==============="

yum_install https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
yum_install http://rpms.remirepo.net/enterprise/remi-release-6.rpm
yum_install yum-utils
yum-config-manager --enable remi-php70
yum_update

echo ""
echo "########################################"
echo "##### Installing Required Packages #####"
echo "########################################"

yum_install /usr/bin/scp
yum_install perl

yum_install ant bind-utils condor-all git patch
yum_install libguestfs libguestfs-tools libguestfs-tools-c libvirt
yum_install httpd mod_ssl php php-mcrypt php-mysqlnd php-mbstring php-pecl-zip php-xml
yum_install MariaDB
yum_install zip ncompress

"$BINDIR"/set-up-common-post.bash
