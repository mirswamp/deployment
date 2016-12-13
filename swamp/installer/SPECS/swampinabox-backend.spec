# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

#
# spec file for the SWAMP-in-a-Box backend
#
%define _arch noarch

#%define __spec_prep_post	%{___build_post}
#%define ___build_post	exit 0
#%define __spec_prep_cmd /bin/sh
#%define __build_cmd /bin/sh
#%define __spec_build_cmd %{__build_cmd}
#%define __spec_build_template	#!%{__spec_build_shell}
%define _target_os Linux

Summary: SWAMP-in-a-Box backend applications, modules and database for Software Assurance Marketplace (SWAMP)
Name: swampinabox-backend
Version: %(perl -e 'print $ENV{RELEASE_NUMBER}')
Release: %(perl -e 'print $ENV{BUILD_NUMBER}')
License: Apache 2.0
Group: Development/Tools
Source: swampinabox-1.tar.gz
URL: http://www.continuousassurance.org
Vendor: The Morgridge Institute for Research
Packager: Support <support@continuousassurance.org>
BuildRoot: /tmp/%{name}-buildroot
BuildArch: noarch
Requires: libguestfs-tools, swamp-rt-java, swamp-rt-perl
Obsoletes: swamponabox-backend
AutoReqProv: no

%description
A state-of-the-art facility designed to advance our nation's cybersecurity by improving the security and reliability of open source software.
This RPM contains the Data Server, Submit Server, Exec packages

%prep
%setup -c

%build
echo "Here's where I am at build $PWD"
cd ../BUILD/%{name}-%{version}

%install
%include swampinabox-install.txt

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,swa-daemon,swa-daemon)
%include swampinabox-files.txt

%pre
%include common-pre.txt

# turn off services
if [ "$1" == "2" ]
then
    service swamp stop
fi

%post
%include common-post.txt
%include swampinabox-post-general.txt
%include swampinabox-post-directory.txt
%include swampinabox-post-data.txt
%include swampinabox-post-submit.txt
%include swampinabox-post-exec.txt

# chkconfig
# install
if [ "$1" == "1" ]
then
    chkconfig --add swamp
    chkconfig swamp on
# upgrade
elif [ "$1" == "2" ]
then
    chkconfig swamp on
fi

# turn on services
# install
if [ "$1" == "1" ]
then
    service swamp start
# upgrade
elif [ "$1" == "2" ]
then
    service swamp start
fi
