# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

#
# spec file for SWAMP dataserver initialization RPM
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


Summary: Directory Server setup for Software Assurance Marketplace (SWAMP) 
Name: swamp-directory-server-setup
Version: %(perl -e 'print $ENV{RELEASE_NUMBER}')
Release: %(perl -e 'print $ENV{BUILD_NUMBER}')
License: Apache 2.0
Group: Development/Tools
Source: swamp-1.tar.gz
URL: http://www.continuousassurance.org
Vendor: The Morgridge Institute for Research
Packager: Support <support@continuousassurance.org>
BuildRoot: /tmp/%{name}-buildroot
BuildArch: noarch
Requires: MariaDB-server,MariaDB-client,openldap-servers
Conflicts: swamp-rt-perl,swamp-exec,swamp-submit,swamp-dataserver-setup
AutoReqProv: no

%description
A state-of-the-art facility designed to advance our nation's cybersecurity by improving the security and reliability of open source software.
This RPM contains the directory server setup scripts

%prep
%setup -c

%build
echo "Here's where I am at build $PWD"
cd ../BUILD/%{name}-%{version}
make install
%install
echo rm -rf $RPM_BUILD_ROOT
echo "At install i am $PWD"
%if %is_darwin
cd %{name}-%{version}
%endif
echo $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/tmp/swamp/Directory_Server
mkdir -p $RPM_BUILD_ROOT/etc/my.cnf.d
mkdir -p $RPM_BUILD_ROOT/etc/openldap/schema
mkdir -p $RPM_BUILD_ROOT/var/lib/ldap
install -m 444 Directory_Server/user_setup.sql $RPM_BUILD_ROOT/tmp/swamp/Directory_Server
install -m 444 Directory_Server/project_tables.sql $RPM_BUILD_ROOT/tmp/swamp/Directory_Server
install -m 444 Directory_Server/populate_project.sql $RPM_BUILD_ROOT/tmp/swamp/Directory_Server
install -m 444 directory_svr/server.cnf $RPM_BUILD_ROOT/etc/my.cnf.d/server-swamp.cnf
install -m 444 directory_svr/mysql-clients.cnf $RPM_BUILD_ROOT/etc/my.cnf.d
install -m 444 directory_svr/mysql_replication.cnf $RPM_BUILD_ROOT/etc/my.cnf.d
install -m 644 directory_svr/ldap_files/60eduperson.schema $RPM_BUILD_ROOT/etc/openldap/schema
install -m 644 directory_svr/ldap_files/70cosalabswamp_enabled.schema $RPM_BUILD_ROOT/etc/openldap/schema
install -m 644 directory_svr/ldap_files/71grouper.schema $RPM_BUILD_ROOT/etc/openldap/schema
install -m 644 directory_svr/ldap_files/slapd.conf $RPM_BUILD_ROOT/etc/openldap/slapd.conf.swamp
install -m 600 directory_svr/ldap_files/DB_CONFIG $RPM_BUILD_ROOT/var/lib/ldap/DB_CONFIG.swamp

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root, root)
/tmp/swamp/Directory_Server/user_setup.sql
/tmp/swamp/Directory_Server/project_tables.sql
/tmp/swamp/Directory_Server/populate_project.sql

%config /etc/my.cnf.d/server-swamp.cnf
%config /etc/my.cnf.d/mysql-clients.cnf
%config /etc/my.cnf.d/mysql_replication.cnf
%config /etc/openldap/slapd.conf.swamp
%config /etc/openldap/schema/60eduperson.schema
%config /etc/openldap/schema/70cosalabswamp_enabled.schema
%config /etc/openldap/schema/71grouper.schema
%config %attr(-,ldap,ldap) /var/lib/ldap/DB_CONFIG.swamp
%pre
service mysql stop
%post
mv /etc/my.cnf.d/server.cnf /etc/my.cnf.d/server.cnf.orig
mv /etc/my.cnf.d/server-swamp.cnf /etc/my.cnf.d/server.cnf
service mysql start
# If this is the first time this RPM has been installed...
if [ "$1" = "1" ] 
then
# From script
echo Defining user database
mysql -u root < /tmp/swamp/Directory_Server/user_setup.sql

echo Defining project database
mysql -u root < /tmp/swamp/Directory_Server/project_tables.sql

echo Populating project database
mysql -u root < /tmp/swamp/Directory_Server/populate_project.sql
echo Cleaning up...
/bin/rm -rf /tmp/swamp
echo Done
echo Do not forget to secure the database per MariaDB instructions.
echo Do not forget to configure the database replication
echo Do not forget to configure ldap with the SWAMP .ldif files and merge /etc/openldap/slapd.conf.swamp
else 
	echo This package has alreadly been installed, will not drop database.
fi
%preun
#service swamp stop
#chkconfig --del swamp
