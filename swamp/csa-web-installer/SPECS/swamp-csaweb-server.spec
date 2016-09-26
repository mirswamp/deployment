# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

#
# spec file for SWAMP CSA web server installation RPM
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
%define __jar_repack 0
%define __os_install_post %{nil}

Summary: CSA Web Server installation for Software Assurance Marketplace (SWAMP) 
Name: swamp-csaweb
Version: %(perl -e 'print $ENV{RELEASE_NUMBER}')
Release: %(perl -e 'print $ENV{BUILD_NUMBER}')
License: Apache 2.0
Group: Development/Tools
Source: swamp.tar
URL: http://www.continuousassurance.org
Vendor: The Morgridge Institute for Research
Packager: Support <support@continuousassurance.org>
BuildRoot: /tmp/%{name}-buildroot
BuildArch: noarch
Requires: httpd,mod_security_crs,php,mod_ssl,php-common,php-ldap,java-1.6.0-openjdk-devel
# Conflicts: swamp-rt-perl,swamp-exec,swamp-submit,swamp-registry-web-server
AutoReqProv: no

%description
A state-of-the-art facility designed to advance our nation's cybersecurity by improving the security and reliability of open source software.
This RPM contains the CSA Web Server packages

%prep
%setup -c -q

%build
%install
%if %is_darwin
cd %{name}-%{version}
%endif

mkdir -p $RPM_BUILD_ROOT/var/www
mkdir -p $RPM_BUILD_ROOT/usr/local/bin

# install source files
/bin/rm -rf $RPM_BUILD_ROOT/var/www/csa
/bin/cp -r csa $RPM_BUILD_ROOT/var/www 
mv $RPM_BUILD_ROOT/var/www/csa/.env.dev $RPM_BUILD_ROOT/var/www/csa/.env
chmod 400 $RPM_BUILD_ROOT/var/www/csa/.env
rm -f $RPM_BUILD_ROOT/var/www/csa/.env.local

%clean
rm -rf $RPM_BUILD_ROOT

%files 
%defattr(-,apache,apache)

/var/www/csa

%pre
if [ "$1" = "2" ]; then
	# preserve existing .env file
	if [ -f /var/www/csa/.env ]; then
		mv /var/www/csa/.env /tmp/.
	fi
fi


%post
if [ "$1" = "2" ]; then
	# restore original .env file
	if [ -f /tmp/.env ]; then
		mv /tmp/.env /var/www/csa/.
		chown apache:apache /var/www/csa/.env
		chmod 400 /var/www/csa/.env
	fi
fi

cd /var/www/csa
/bin/rm -f /var/www/csa/public/downloads /var/www/csa/public/results /var/www/csa/public/uploads
/bin/ln -s /swamp/outgoing /var/www/csa/public/downloads
/bin/ln -s /var/www/html/results /var/www/csa/public/results
/bin/ln -s /swamp/incoming /var/www/csa/public/uploads
[ ! -L /var/www/csa/public/downloads ] && echo ERROR: '/bin/ln -s /swamp/outgoing /var/www/csa/public/downloads' failed
[ ! -L /var/www/csa/public/results ] && echo ERROR: '/bin/ln -s /var/www/html/results /var/www/csa/public/results' failed
[ ! -L /var/www/csa/public/uploads ] && echo ERROR: '/bin/ln -s /swamp/incoming /var/www/csa/public/uploads' failed

chown -R apache:apache /var/www/csa

%preun
