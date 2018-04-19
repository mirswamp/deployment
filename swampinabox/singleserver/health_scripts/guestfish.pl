#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

use strict;
use warnings;
use Getopt::Long;

my $debug = 0;
my $verbose = 0;

sub guestfish_fetch_file { my ($vmname, $file, $preserve) = @_ ;
	print "Fetching: $file from: $vmname with preserve: $preserve\n";
	my $result;
    if ($preserve) {
    	$result = `virt-copy-out -d $vmname -m /dev/sdc:/mnt/out -m /dev/sdb:/mnt/in $file .`;
    }
    else {
    	$result = `guestfish --ro -d $vmname -m /dev/sdc:/mnt/out -m /dev/sdb:/mnt/in -i cat $file 2>&1`;
    }
    return $result;
}

sub guestfish_display_file { my ($vmname, $file, $preserve) = @_ ;
	my $result = guestfish_fetch_file($vmname, $file, $preserve);
	print $result, "\n";
}

sub guestfish_check_status { my ($vmname) = @_ ;
	my $result = guestfish_fetch_file($vmname, '/mnt/out/status.out', 0);
	if (! $result) {
		print "Error - status.out not found in: $vmname\n";
		return;
	}
	my @lines = split "\n", $result;
	my $pass = 0;
	my $finish = 0;
	my $fail;
	foreach my $line (@lines) {
		$pass = 1 if ($line =~ m/PASS:\s+all/);
		$finish = 1 if ($line =~ m/NOTE:\s+end/);
	}
	if ($finish) {
		if ($pass) {
			print "$vmname assessment finished with success\n";
		}
		else {
			print "$vmname assessment finished with failure\n";
		}
	}
	else {
		print "$vmname assessment has not finished\n";
	}
}

sub usage {
	print "usage: $0 [-help -debug -verbose -statusout|-runout|-catalina|-mysql|-codedx <project_uuid>|-file <string> -preserve] <vmname>\n"; 
	exit;
}

usage() if (! @ARGV);

my $help = 0;
my $vmname;
my $file;
my $preserve = 0;
my $runout = 0;
my $catalina = 0;
my $mysql = 0;
my $codedx = 0;
my $statusout = 0;
my $checkstatus = 0;
my $result = GetOptions(
	'help'			=> \$help,
	'debug'			=> \$debug,
	'verbose'		=> \$verbose,
	'file=s'		=> \$file,
	'preserve'		=> \$preserve,
	'runout'		=> \$runout,
	'statusout'		=> \$statusout,
	'catalina'		=> \$catalina,
	'mysql'			=> \$mysql,
	'codedx=s'		=> \$codedx,
	'checkstatus'	=> \$checkstatus,
);
usage() if ($help || ! $result);
$vmname = $ARGV[0] if (defined($ARGV[0]));
usage() if (! $vmname);
$checkstatus = 1 if (! $file && ! $runout && ! $statusout && ! $catalina && ! $mysql && ! $codedx);

guestfish_display_file($vmname, $file, $preserve) if ($file);
guestfish_display_file($vmname, '/mnt/out/run.out', $preserve) if ($runout);
guestfish_display_file($vmname, '/mnt/out/status.out', $preserve) if ($statusout);
guestfish_display_file($vmname, '/var/log/tomcat6/catalina.out', $preserve) if ($catalina);
guestfish_display_file($vmname, "/var/lib/mysql/$vmname.err", $preserve) if ($mysql);
guestfish_display_file($vmname, "/var/lib/codedx/proxy-${codedx}/config/log-files/codedx.log", $preserve) if ($codedx);
guestfish_check_status($vmname) if ($checkstatus);
