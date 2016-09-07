#
# spec file for SWAMPONABOX
#
%define _arch noarch

#%define __spec_prep_post	%{___build_post}
#%define ___build_post	exit 0
#%define __spec_prep_cmd /bin/sh
#%define __build_cmd /bin/sh
#%define __spec_build_cmd %{__build_cmd}
#%define __spec_build_template	#!%{__spec_build_shell}
%define _target_os Linux


Summary: Swamponabox backend applications, modules and database for Software Assurance Marketplace (SWAMP) 
Name: swamponabox-backend
Version: %(perl -e 'print $ENV{RELEASE_NUMBER}')
Release: %(perl -e 'print $ENV{BUILD_NUMBER}')
License: Apache 2.0
Group: Development/Tools
Source: swamponabox-1.tar.gz
URL: http://www.continuousassurance.org
Vendor: The Morgridge Institute for Research
Packager: Support <support@continuousassurance.org>
BuildRoot: /tmp/%{name}-buildroot
BuildArch: noarch
Requires: libguestfs-tools, swamp-rt-java, swamp-rt-perl
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
%include swamponabox-install.txt

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,swa-daemon, swa-daemon)
%include swamponabox-files.txt

%pre
# turn off services
# install
if [ "$1" == "1" ]
then
	echo "pre install"
# upgrade
elif [ "$1" == "2" ]
then
	echo "pre upgrade"
	service swamp stop
fi

%post
%include swamponabox-post-directory.txt
%include swamponabox-post-data.txt
%include swamponabox-post-submit.txt
%include swamponabox-post-exec.txt

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
