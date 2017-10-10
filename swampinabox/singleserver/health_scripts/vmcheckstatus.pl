#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

use strict;
use warnings;
use Getopt::Long;

my $debug = 0;
my $verbose = 0;

sub guestfish_check_status { my ($vmname) = @_ ;
	my $file = '/mnt/out/status.out';
	my $result = `guestfish --ro -d $vmname -m /dev/sdc:/mnt/out -m /dev/sdb:/mnt/in -i cat $file 2>/dev/null`;
	if (! $result) {
		print "Error - $file not found\n";
		return;
	}
	my @lines = split "\n", $result;
	my $pass = 0;
	my $finish = 0;
	my $fail = 0;
	foreach my $line (@lines) {
		$pass = 1 if ($line =~ m/PASS:\s+all/);
		$finish = 1 if ($line =~ m/NOTE:\s+end/);
		$fail = 1 if ($line =~ m/FAIL:/);
	}
	if ($finish) {
		if ($pass) {
			print "assessment finished with success\n";
		}
		elsif ($fail) {
			print "assessment finished with failure\n";
		}
		else {
			print "fatal error - no termination status\n";
		}
	}
	else {
		if ($pass) {
			print "assessment has passed but not terminated\n";
		}
		elsif ($fail) {
			print "assessment has failed but not terminated\n";
		}
		else {
			print "assessment is currently active\n";
		}
	}
	if ($verbose) {
		print "$result\n";
	}
}

sub usage {
	print "usage: $0 [-help -debug -verbose <vmname>]\n"; 
	exit;
}

my $help = 0;
my $result = GetOptions(
	'help'			=> \$help,
	'debug'			=> \$debug,
	'verbose'		=> \$verbose,
);
usage() if ($help || ! $result);
my @vmnames = ();
if (defined($ARGV[0])) {
	push @vmnames, $ARGV[0];
}
else {
	@vmnames = `virsh list --name`;
	chomp @vmnames;
}
foreach my $vmname (@vmnames) {
	if ($vmname) {
		print "$vmname ";
		guestfish_check_status($vmname);
	}
}
