# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

#
# spec file for SWAMP web server installation RPM
#
%define _arch noarch

%define _target_os Linux
# Leave our files alone
%define __jar_repack 0
%define __os_install_post %{nil}


Summary: Web Server installation for Software Assurance Marketplace (SWAMP)
Name: swamp-web-server
Version: %(perl -e 'print $ENV{RELEASE_NUMBER}')
Release: %(perl -e 'print $ENV{BUILD_NUMBER}')
License: Apache 2.0
Group: Development/Tools
Source: swamp-1.tar
URL: http://www.continuousassurance.org
Vendor: The Morgridge Institute for Research
Packager: Support <support@continuousassurance.org>
BuildRoot: /tmp/%{name}-buildroot
BuildArch: noarch
Requires: httpd, mod_ssl, php
AutoReqProv: no

%description
A state-of-the-art facility designed to advance our nation's cybersecurity by improving the security and reliability of open source software.
This RPM contains the Web Server packages

%prep
%setup -c -q

%build
echo "Start of RPM build script: $PWD"

%install
echo "Start of RPM install script: $PWD"

mkdir -p $RPM_BUILD_ROOT/var/www
/bin/rm -rf $RPM_BUILD_ROOT/var/www/swamp-web-server
/bin/rm -rf $RPM_BUILD_ROOT/var/www/html

cp -r html $RPM_BUILD_ROOT/var/www
cp -r swamp-web-server $RPM_BUILD_ROOT/var/www

mv $RPM_BUILD_ROOT/var/www/html/config/config.sample.json $RPM_BUILD_ROOT/var/www/html/config/config.json
mv $RPM_BUILD_ROOT/var/www/swamp-web-server/env.sample $RPM_BUILD_ROOT/var/www/swamp-web-server/.env

find $RPM_BUILD_ROOT -type f -exec chmod 0644 '{}' ';'
find $RPM_BUILD_ROOT -type d -exec chmod 0755 '{}' ';'
chmod 400 $RPM_BUILD_ROOT/var/www/swamp-web-server/.env

%clean
rm -rf $RPM_BUILD_ROOT

# CSA-2846: Don't make everything owned by `apache`.
# N.B. Make sure that the %post script below and the SWAMP-in-a-Box
# installer maintains these attributes for the %config files.
%files
%defattr(-,root,root)

%attr(0444, root,   root)   %config /var/www/html/config/config.json
%attr(0400, apache, apache) %config /var/www/swamp-web-server/.env
%attr(0755, apache, apache) /var/www/swamp-web-server/storage/app
%attr(0755, apache, apache) /var/www/swamp-web-server/storage/framework
%attr(0755, apache, apache) /var/www/swamp-web-server/storage/framework/cache
%attr(0755, apache, apache) /var/www/swamp-web-server/storage/framework/sessions
%attr(0755, apache, apache) /var/www/swamp-web-server/storage/framework/views
%attr(0755, apache, apache) /var/www/swamp-web-server/storage/logs

/var/www/html/*
/var/www/html/.[A-Za-z]*
/var/www/swamp-web-server

%pre
if [ "$1" = "2" ]; then
    # preserve config.js just to assist in manual conversion to json
    if [ -f /var/www/html/scripts/config/config.js ]; then
        # found a config file from 1.28 or later
        mv /var/www/html/scripts/config/config.js /var/www/html/scripts/config/config.js.swampsave
    elif [ -f /var/www/html/scripts/config.js ]; then
        # found a config file from 1.27 or earlier
        mv /var/www/html/scripts/config.js /var/www/html/scripts/config.js.swampsave
    fi
    # preserve config.json
    if [ -f /var/www/html/config/config.json ]; then
        cp /var/www/html/config/config.json /tmp/.
    fi
fi

%post
if [ "$1" = "2" ]; then
    # restore config.json
    if [ -f /tmp/config.json ]; then
        mv /tmp/config.json /var/www/html/config/config.json
    fi
fi

# Preserve .env settings
#
# We go through this path for both installs and upgrades because the
# SWAMP-in-a-Box installer needs to erase the 1.27 version of the RPM
# instead of allowing yum/rpm to upgrade it normally.
#
if [ -r /var/www/swamp-web-server/.env.rpmsave ]; then
    src=/var/www/swamp-web-server/.env.rpmsave
    dest=/var/www/swamp-web-server/.env

    conf_keys=$(awk -F= '{print $1}' "$dest" | awk '{print $1}' | grep -E '^[^#]')

    echo Beginning to update $dest from $src

    while read -r key; do
        if grep -q "^\s*$key\s*=" "$src" 1>/dev/null 2>/dev/null; then
            echo Updating $key

            val=$(grep "^\s*$key\s*=" "$src" | sed "s/^\s*$key\s*=\s*\(.*\)$/\1/")

            # Escape special characters for sed's 's//'
            val=${val//\\/\\\\}  # escape back slash
            val=${val//\//\\\/}  # escape forward slash
            val=${val//&/\\&}    # escape ampersands

            sed -i "s/^\s*$key\s*=.*$/$key=$val/" "$dest"
        fi
    done <<< "$conf_keys"

    echo Finished updating $dest
fi

# CSA-2846: Enforce permissions on %config files.
chown root:root     /var/www/html/config/config.json
chmod 0444          /var/www/html/config/config.json
chown apache:apache /var/www/swamp-web-server/.env
chmod 0400          /var/www/swamp-web-server/.env

%preun
