#
# spec file for SWAMP api server installation RPM
#
%define is_darwin %(test -e /Applications && echo 1 || echo 0)
%if %is_darwin
%define _topdir	 	/Users/dboulineau/Projects/cosa/trunk/swamp/src/main/deployment/swamp/installer
%define nil #
%define _rpmfc_magic_path   /usr/share/file/magic
%define __os Linux
%endif
%define _arch noarch

#%define __spec_prep_post	%{___build_post}
#%define ___build_post	exit 0
#%define __spec_prep_cmd /bin/sh
#%define __build_cmd /bin/sh
#%define __spec_build_cmd %{__build_cmd}
#%define __spec_build_template	#!%{__spec_build_shell}
%define _target_os Linux
# Leave our files alone
%define __jar_repack 0
%define __os_install_post %{nil}


Summary: API Server installation for Software Assurance Marketplace (SWAMP) 
Name: swamp-api
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
Requires: httpd,mod_security_crs,php,mod_ssl
Conflicts: swamp-rt-perl,swamp-exec,swamp-submit,swamp-csaweb
AutoReqProv: no

%description
A state-of-the-art facility designed to advance our nation's cybersecurity by improving the security and reliability of open source software.
This RPM contains the Registry Web Server packages

%prep
%setup -c -q

%build
echo "Here's where I am at build $PWD"
#cd ../BUILD/%{name}-%{version}
#make install
%install
echo rm -rf $RPM_BUILD_ROOT
echo "At install i am $PWD"
%if %is_darwin
cd %{name}-%{version}
%endif

mkdir -p $RPM_BUILD_ROOT/var/www
mkdir -p $RPM_BUILD_ROOT/usr/local/bin
# CSA-1860 install -m 755 composer $RPM_BUILD_ROOT/usr/local/bin
/bin/rm -rf $RPM_BUILD_ROOT/var/www/swamp-api
cp -r swamp-api $RPM_BUILD_ROOT/var/www
mv $RPM_BUILD_ROOT/var/www/swamp-api/app/config.sample $RPM_BUILD_ROOT/var/www/swamp-api/app/config

%clean
rm -rf $RPM_BUILD_ROOT

%files 
%attr(-,apache,apache) %config /var/www/swamp-api/app/config/app.php
%attr(-,apache,apache) %config /var/www/swamp-api/bootstrap/start.php 
%dir /var/www/swamp-api
%attr(-,apache,apache) /var/www/swamp-api
%defattr(-,apache, apache)
# CSA-1860 /usr/local/bin/composer 

%pre

%post

cd /var/www/swamp-api
# CSA-1860 #/usr/local/bin/composer selfupdate
iam=`hostname -s`
nodev=""
# Avoid php unit on integration or production
if [ "$iam" = "swa-api-it-01" -o "$iam" = "swa-api-pd-01" ];then
nodev="--no-dev"
fi
# CSA-1860 /usr/local/bin/composer install 
# CSA-1860 /usr/local/bin/composer dump-autoload
chown -R apache:apache /var/www/swamp-api

host=""
if [ "$iam" = "swa-api-dt-01" -o "$iam" = "swa-build-1" -o "$iam" = "dbrhel6test"  ];then
host=swa-dir-dt-02
elif [ "$iam" = "swa-api-it-01" ];then
host=swa-dir-it-01
elif [ "$iam" = "swa-api-pd-01" ];then
host=swa-dir-pd-01
fi

#fix up session.php to use secure connections only
/bin/sed -i -e's/'\'secure\''.*=>.*false/'\'secure\'' => true/' /var/www/swamp-api/app/config/session.php

# Fixup database.php based on our environment
if [ "$host" != "" ];then
# This sed script replaces the host after the mysql driver with the
# correct directory server.
/bin/sed -i -e'/driver.*'mysql'/ {
n
c '\'host\'' => '\'$host\'',
}' /var/www/swamp-api/app/config/database.php

else
    echo Please update the mysql 'host' item in /var/www/swamp-api/app/config/database.php with the name of the Directory Server
fi

%preun
