# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

#
# spec file for SWAMP
#
%define _arch noarch

%define __spec_prep_post	%{___build_post}
%define ___build_post	exit 0
%define __spec_prep_cmd /bin/sh
%define __build_cmd /bin/sh
%define __spec_build_cmd %{__build_cmd}
%define __spec_build_template	#!%{__spec_build_shell}
%define _target_os Linux

Summary: Data Server applications for Software Assurance Marketplace (SWAMP) 
Name: swamp-directory-server
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
Requires: swamp-directory-server-setup
Conflicts: swamp-exec, swamp-dataserver, swamp-submit
AutoReqProv: no

%description
A state-of-the-art facility designed to advance our nation's cybersecurity by improving the security and reliability of open source software.
This RPM contains the DirectoryServer SQL scripts

%prep
%setup -c

%build
echo "Here's where I am at build $PWD"
cd ../BUILD/%{name}-%{version}
%install
%include common-install-directory.txt
%include swamp-install-directory.txt

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root, root)
%include common-files-directory.txt
%include swamp-files-directory.txt

%post
if [ -r /etc/.mysql ]
then
    pass=`openssl enc -d -aes-256-cbc -in /etc/.mysql  -pass pass:swamp`
    echo '[client]' > /opt/swamp/sql/sql.cnf
    # Chmod ASAP
    chmod 400 /opt/swamp/sql/sql.cnf
    echo password=$pass >> /opt/swamp/sql/sql.cnf
    echo user=root >> /opt/swamp/sql/sql.cnf
    opt=--defaults-file=/opt/swamp/sql/sql.cnf
    # Are we upgrading?
    if [ "$1" = "2" ] 
    then
        if [ -r /opt/swamp/sql/upgrades_directory/upgrade_script.sql ]
        then
            echo 'Running SQL upgrades_directory script(s) against database...'
            cd /opt/swamp/sql/upgrades_directory
            mysql $opt < upgrade_script.sql
        fi
    fi
    # Run the sql scripts against the DS
    echo Running SQL scripts against database...
    echo Project
    mysql $opt < /opt/swamp/sql/project_procs.sql 
    /bin/rm -f /opt/swamp/sql/sql.cnf
else
    echo Unable to infer the password to mysql, unable to run scripts.
fi
%preun
