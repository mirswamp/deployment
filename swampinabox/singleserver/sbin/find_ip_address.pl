#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

use strict;
use warnings;
use Socket;

my $hostname = '';
if (defined($ARGV[0])) {
	$hostname = $ARGV[0];
}
else {
	$hostname = $ENV{HOSTNAME};
}
my $address = '';
if ($hostname) {
	my $aton = inet_aton($hostname);
	if ($aton) {
		$address = inet_ntoa($aton);
	}
	else {
		$address = (split ' ', `hostname -I`)[0];
		my $bogus = 0;
	}
}
print $address || '';
