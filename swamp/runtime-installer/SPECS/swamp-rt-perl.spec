# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

%define is_darwin %(test -e /Applications && echo 1 || echo 0)
%if %is_darwin
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


Summary: Runtime Perl libraries for Software Assurance Marketplace (SWAMP)
Name: swamp-rt-perl
Version: %(perl -e 'print $ENV{RELEASE_NUMBER}')
Release: %(perl -e 'print $ENV{BUILD_NUMBER}')
License: Apache 2.0
Group: Development/Tools
Source: runtime.tar.gz
URL: http://www.continuousassurance.org
Vendor: The Morgridge Institute for Research
Packager: Support <support@continuousassurance.org>
BuildRoot: /tmp/%{name}-buildroot
BuildArch: noarch
Obsoletes: swamp-rt,swamp-rt-exec
# Conflicts: swamp-rt-rws
%description
This RPM contains the runtime Perl and Perl modules used by SWAMP
A state-of-the-art facility designed to advance our nation's cybersecurity by improving the security and reliability of open source software.

%prep
%setup -c

%build
echo "Here's where I am at build $PWD"
cd ../BUILD/%{name}-%{version}
#make install
%install
echo rm -rf $RPM_BUILD_ROOT
%if %is_darwin
cd %{name}-%{version}
%endif
mkdir -p $RPM_BUILD_ROOT/usr/local/empty
mkdir -p $RPM_BUILD_ROOT/tmp
cp perlbrew.tgz $RPM_BUILD_ROOT/tmp

%clean
rm -rf $RPM_BUILD_ROOT

%post
/bin/rm -rf $RPM_BUILD_ROOT/opt/perl5
cd $RPM_BUILD_ROOT/opt
tar xzf $RPM_BUILD_ROOT/tmp/perlbrew.tgz
rm -f $RPM_BUILD_ROOT/tmp/perlbrew.tgz
chown -R swa-daemon:swa-daemon /opt/perl5

%files
%defattr(-,swa-daemon, swa-daemon)
#%doc README TODO COPYING ChangeLog
/tmp/perlbrew.tgz

%postun 
# Only remove things if this is an uninstall
if [ "$1" = "0" ] 
then
    /bin/rm -rf /opt/perl5
fi
