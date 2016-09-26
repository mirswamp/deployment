# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

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
Requires: httpd,php,mod_ssl
AutoReqProv: no

%description
A state-of-the-art facility designed to advance our nation's cybersecurity by improving the security and reliability of open source software.
This RPM contains the Web Server packages

%prep
%setup -c -q

%build
echo "Here's where I am at build $PWD"
%install
echo rm -rf $RPM_BUILD_ROOT
echo "At install i am $PWD"

mkdir -p $RPM_BUILD_ROOT/var/www
mkdir -p $RPM_BUILD_ROOT/usr/local/bin

/bin/rm -rf $RPM_BUILD_ROOT/var/www/swamp-web-server
/bin/rm -rf $RPM_BUILD_ROOT/var/www/html

# install source files
cp -r swamp-web-server $RPM_BUILD_ROOT/var/www
cp -r html $RPM_BUILD_ROOT/var/www
mv $RPM_BUILD_ROOT/var/www/html/scripts/config.js.sample $RPM_BUILD_ROOT/var/www/html/scripts/config.js
mv $RPM_BUILD_ROOT/var/www/swamp-web-server/.env.sample $RPM_BUILD_ROOT/var/www/swamp-web-server/.env
chmod 400 $RPM_BUILD_ROOT/var/www/swamp-web-server/.env

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,apache,apache)
%attr(-,apache,apache) %config /var/www/html/scripts/config.js
%attr(-,apache,apache) %config /var/www/swamp-web-server/.env
%attr(-,apache,apache) /var/www/html/*
%attr(-,apache,apache) /var/www/html/.[A-Za-z]*
%attr(-,apache,apache) /var/www/swamp-web-server

%pre
if [ "$1" = "2" ]; then
	# preserve config.js and .env files
	if [ -f /var/www/html/scripts/config.js ]; then
		cp /var/www/html/scripts/config.js /tmp/.
	fi
	if [ -f /var/www/swamp-web-server/.env ]; then
		mv /var/www/swamp-web-server/.env /tmp/.
	fi
fi


%post
if [ "$1" = "2" ]; then
	# restore original config.js and .env files
	if [ -f /tmp/config.js ]; then
		mv /tmp/config.js /var/www/html/scripts/config.js
	fi
	if [ -f /tmp/.env ]; then
		mv /tmp/.env /var/www/swamp-web-server/.
		chown apache:apache /var/www/swamp-web-server/.env
		chmod 400 /var/www/swamp-web-server/.env
	fi
fi


cd /var/www/swamp-web-server
chown -R apache:apache /var/www/swamp-web-server

%preun
