#!/usr/bin/env perl
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
