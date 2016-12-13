# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

#
# spec file for SWAMP directory server installation RPM
#
%define is_darwin %(test -e /Applications && echo 1 || echo 0)
%if %is_darwin
%define _topdir	 	/Users/dboulineau/Projects/cosa/trunk/swamp/src/main/deployment/swamp/installer
%define nil #
%define _rpmfc_magic_path   /usr/share/file/magic
%define __os Linux
%endif
%define _arch noarch

%define _target_os Linux
# Leave our files alone
%define __jar_repack 0
%define __os_install_post %{nil}


Summary: Registry Web Server installation for Software Assurance Marketplace (SWAMP) 
Name: swamp-registry-web-server
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
# Conflicts: swamp-rt-perl,swamp-exec,swamp-submit,swamp-csaweb
AutoReqProv: no

%description
A state-of-the-art facility designed to advance our nation's cybersecurity by improving the security and reliability of open source software.
This RPM contains the Registry Web Server packages

%prep
%setup -c -q

%build
echo "Here's where I am at build $PWD"
%install
echo rm -rf $RPM_BUILD_ROOT
echo "At install i am $PWD"
%if %is_darwin
cd %{name}-%{version}
%endif

mkdir -p $RPM_BUILD_ROOT/var/www
mkdir -p $RPM_BUILD_ROOT/usr/local/bin

/bin/rm -rf $RPM_BUILD_ROOT/var/www/rws
/bin/rm -rf $RPM_BUILD_ROOT/var/www/html

# install source files
cp -r rws $RPM_BUILD_ROOT/var/www
cp -r html $RPM_BUILD_ROOT/var/www
mv $RPM_BUILD_ROOT/var/www/html/scripts/config/config.js.sample $RPM_BUILD_ROOT/var/www/html/scripts/config/config.js
mv $RPM_BUILD_ROOT/var/www/rws/.env.dev $RPM_BUILD_ROOT/var/www/rws/.env
chmod 400 $RPM_BUILD_ROOT/var/www/rws/.env
rm -f $RPM_BUILD_ROOT/var/www/rws/.env.local


%clean
rm -rf $RPM_BUILD_ROOT

%files 
%attr(-,apache,apache) %config /var/www/html/scripts/config/config.js
%dir /var/www/html
%dir /var/www/rws
%attr(-,apache,apache) /var/www/html
%attr(-,apache,apache) /var/www/rws
%defattr(-,apache,apache)

%pre
if [ "$1" = "2" ]; then
	# preserve config.js and .env files
	if [ -f /var/www/html/scripts/config/config.js ]; then
		cp /var/www/html/scripts/config/config.js /tmp/.
	fi
	if [ -f /var/www/rws/.env ]; then
		mv /var/www/rws/.env /tmp/.
	fi
fi


%post
if [ "$1" = "2" ]; then
	# restore original config.js and .env files
	if [ -f /tmp/config.js ]; then
		mv /tmp/config.js /var/www/html/scripts/config/config.js
	fi
	if [ -f /tmp/.env ]; then
		mv /tmp/.env /var/www/rws/.
		chown apache:apache /var/www/rws/.env
		chmod 400 /var/www/rws/.env
	fi
fi


cd /var/www/rws
chown -R apache:apache /var/www/rws

%preun
