#!/bin/bash
# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

# This script is for /etc/profile.d

# add /usr/sbin for condor_advertise
if [[ ! "$PATH" =~ "/usr/sbin" ]]
then
	export PATH="/usr/sbin:$PATH"
fi

# add perl-runtime
perl_version='5.26.1'
if [ -r /opt/swamp/etc/dependencies.txt ]
then
	perl_version=$(grep perl /opt/swamp/etc/dependencies.txt | sed 's/perl://')
fi
perl_path="/opt/perl5/perls/perl-$perl_version/bin/"
# echo "perl_version: $perl_version"
# echo "perl_path: $perl_path"
# echo "PATH: $PATH"
if [[ ! "$PATH" =~ "$perl_version" ]]
then
	# echo "export PATH=$perl_path:$PATH"
	export PATH="$perl_path:$PATH"
# else
	# echo "PATH unchanged: $PATH"
fi

# add htcondor runtime
if [[ ! "$PATH" =~ "htcondor" ]]
then
	if [ -r /opt/swamp/htcondor/condor.sh ]
	then
		source /opt/swamp/htcondor/condor.sh
	fi
fi
