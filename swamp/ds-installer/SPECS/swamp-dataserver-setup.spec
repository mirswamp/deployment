# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

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


Summary: Data Server initialization for Software Assurance Marketplace (SWAMP) 
Name: swamp-dataserver-setup
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
Requires: MariaDB-server,MariaDB-client
Conflicts: swamp-exec,swamp-submit,swamp-directory-server-setup
AutoReqProv: no

%description
A state-of-the-art facility designed to advance our nation's cybersecurity by improving the security and reliability of open source software.
This RPM contains the data server setup packages

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
mkdir -p $RPM_BUILD_ROOT/tmp/swamp/Data_Server
mkdir -p $RPM_BUILD_ROOT/etc/my.cnf.d
mkdir -p $RPM_BUILD_ROOT/usr/lib64/mysql/plugin
install -m 444 Data_Server/user_setup.sql  $RPM_BUILD_ROOT/tmp/swamp/Data_Server
install -m 444 Data_Server/sys_exec.sql  $RPM_BUILD_ROOT/tmp/swamp/Data_Server
install -m 444 Data_Server/Platform_Store/platform_store_tables.sql  $RPM_BUILD_ROOT/tmp/swamp/Data_Server
install -m 444 Data_Server/Tool_Shed/tool_shed_tables.sql  $RPM_BUILD_ROOT/tmp/swamp/Data_Server
install -m 444 Data_Server/Viewer_Store/viewer_store_tables.sql  $RPM_BUILD_ROOT/tmp/swamp/Data_Server
install -m 444 Data_Server/Package_Store/package_store_tables.sql  $RPM_BUILD_ROOT/tmp/swamp/Data_Server
install -m 444 Data_Server/Project/project_tables.sql  $RPM_BUILD_ROOT/tmp/swamp/Data_Server
install -m 444 Data_Server/Assessment/assessment_tables.sql  $RPM_BUILD_ROOT/tmp/swamp/Data_Server
install -m 444 Data_Server/Platform_Store/populate_platform_store.sql  $RPM_BUILD_ROOT/tmp/swamp/Data_Server
install -m 444 Data_Server/Tool_Shed/populate_tool_shed.sql  $RPM_BUILD_ROOT/tmp/swamp/Data_Server
install -m 444 Data_Server/Viewer_Store/populate_viewer_store.sql  $RPM_BUILD_ROOT/tmp/swamp/Data_Server
install -m 444 Data_Server/Package_Store/populate_package_store.sql  $RPM_BUILD_ROOT/tmp/swamp/Data_Server
install -m 444 Data_Server/Assessment/populate_assessment.sql $RPM_BUILD_ROOT/tmp/swamp/Data_Server
install -m 444 permissions_svr/server.cnf $RPM_BUILD_ROOT/etc/my.cnf.d/server-swamp.cnf
install -m 444 permissions_svr/mysql-clients.cnf $RPM_BUILD_ROOT/etc/my.cnf.d
install -m 444 permissions_svr/mysql_replication.cnf $RPM_BUILD_ROOT/etc/my.cnf.d
install -m 444 permissions_svr/mysql_global_settings.cnf $RPM_BUILD_ROOT/etc/my.cnf.d
install -m 755 lib_mysqludf_sys.so $RPM_BUILD_ROOT/usr/lib64/mysql/plugin/lib_mysqludf_sys.so

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root, root)
/tmp/swamp/Data_Server/sys_exec.sql
/tmp/swamp/Data_Server/user_setup.sql
/tmp/swamp/Data_Server/platform_store_tables.sql
/tmp/swamp/Data_Server/tool_shed_tables.sql
/tmp/swamp/Data_Server/package_store_tables.sql
/tmp/swamp/Data_Server/project_tables.sql
/tmp/swamp/Data_Server/assessment_tables.sql
/tmp/swamp/Data_Server/viewer_store_tables.sql
/tmp/swamp/Data_Server/populate_platform_store.sql
/tmp/swamp/Data_Server/populate_tool_shed.sql
/tmp/swamp/Data_Server/populate_package_store.sql
/tmp/swamp/Data_Server/populate_assessment.sql
/tmp/swamp/Data_Server/populate_viewer_store.sql
/usr/lib64/mysql/plugin/lib_mysqludf_sys.so

%config /etc/my.cnf.d/server-swamp.cnf
%config /etc/my.cnf.d/mysql-clients.cnf
%config /etc/my.cnf.d/mysql_replication.cnf
%config /etc/my.cnf.d/mysql_global_settings.cnf
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

echo Creating sys_exec function
mysql -u root < /tmp/swamp/Data_Server/sys_exec.sql

echo Defining project database
mysql -u root < /tmp/swamp/Data_Server/project_tables.sql
echo Defining platform store database
mysql -u root < /tmp/swamp/Data_Server/platform_store_tables.sql
echo Defining tool shed database
mysql -u root < /tmp/swamp/Data_Server/tool_shed_tables.sql
echo Defining package store database
mysql -u root < /tmp/swamp/Data_Server/package_store_tables.sql
echo Defining assessment database
mysql -u root < /tmp/swamp/Data_Server/assessment_tables.sql
echo Defining viewer store database
mysql -u root < /tmp/swamp/Data_Server/viewer_store_tables.sql


echo Populating platform store
mysql -u root < /tmp/swamp/Data_Server/populate_platform_store.sql
echo Populating tool shed
mysql -u root < /tmp/swamp/Data_Server/populate_tool_shed.sql
echo Populating package store
mysql -u root < /tmp/swamp/Data_Server/populate_package_store.sql
echo Populating assessment database
mysql -u root < /tmp/swamp/Data_Server/populate_assessment.sql
echo Populating viewer store database
mysql -u root < /tmp/swamp/Data_Server/populate_viewer_store.sql
echo Defining user database
mysql -u root < /tmp/swamp/Data_Server/user_setup.sql

echo Cleaning up...
/bin/rm -rf /tmp/swamp
echo Done
echo Do not forget to secure the database per MariaDB instructions.
echo Do not forget to configure the database replication.
else 
	echo This package has alreadly been installed, will not drop database.
fi
%preun
#service swamp stop
#chkconfig --del swamp
