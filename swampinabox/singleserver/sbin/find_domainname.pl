#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

use strict;
use warnings;
use Net::Domain qw(domainname);

my $domain = `dnsdomainname 2>&1`;
chomp $domain;
if (! $domain || $domain =~ m/Unknown/) {
	$domain = domainname();
}
if (! $domain) {
	my $hostname = '';
	if (defined($ARGV[0])) {
		$hostname = $ARGV[0];
	}
	else {
		$hostname = $ENV{HOSTNAME};
	}
	if ($hostname) {
		my @parts = split '\.', $hostname;
		shift @parts;
		$domain = join '.', @parts;
	}
}
print $domain || '';
