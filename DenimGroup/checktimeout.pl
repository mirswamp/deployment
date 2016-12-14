#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

use strict;
use warnings;
use Time::Local;

my $viewer;
my $swamplog = '/mnt/out/run.out';
my $tomcatlog = '/opt/tomcat/logs/catalina.out';

sub parse_date_to_epoch { my ($date, $parts) = @_ ;
	my %months = (Jan=> 0, Feb=> 1, Mar=> 2, Apr=> 3, May=>4, Jun=> 5, Jul=> 6, Aug=> 7, Sep=> 8, Sep=> 8, Oct=> 9, Nov=> 10, Dec=> 11);
	my ($ymd, $day, $month, $time, $zone, $year);
	my @parts = split ' ', $date;
	return undef if (scalar(@parts) != $parts);
	if ($parts == 6) {
		(undef, $month, $day, $time, $zone, $year) = @parts;
		$month = $months{$month};
	}
	else {
		($ymd, $time) = @parts;
		($year, $month, $day) = split '-', $ymd;
		$month -= 1;
	}
	my ($hour, $min, $sec) = split ':', $time;
	return undef if (! defined($hour) || ! defined($min) || ! defined($sec));
	my $epoch = timelocal($sec, $min, $hour, $day, $month, $year);
	return $epoch;
}

sub find_vm_start_timestamp {
	if (open(my $fh, '<', $swamplog)) {
		my @lines = <$fh>;
		close($fh);
		foreach my $line (@lines) {
			if ($line =~ m/^(.*) Starting $viewer viewer via run.sh$/) {
				my $date = $1;
				last if (! $date);
				my $epoch = parse_date_to_epoch($date, 6);
				last if (! defined($epoch));
				return $epoch;
			}
		}
	}
	return 0;
}

sub find_last_tomcat_timestamp {
	my @epochs = ();
	my $stat_epoch = 0;
	if (-r $tomcatlog) {
		# get mtime from stat on tomcat log file
		$stat_epoch = (stat $tomcatlog)[9];
	}
	if (open(my $fh, '<', $tomcatlog)) {
		my @lines = <$fh>;
		close($fh);
		foreach my $line (@lines) {
            if ($line =~ m/(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}):/) {
				my $date = $1;
				next if (! $date);
				my $epoch = parse_date_to_epoch($date, 2);
				push @epochs, $epoch if (defined($epoch));
			}
		}
		@epochs = reverse sort @epochs;
	}
	return ($stat_epoch, $epochs[0] || 0);
}

$viewer = $ARGV[0] || 'threadfix';
my $CHECKTIMEOUT_LASTLOG = $ARGV[1] || 3600;
my $epoch_now = time();

my $start_epoch = find_vm_start_timestamp();
# if start timestamp not found then runtime will be epoch_now
# this will cause vm to be permitted to shutdown based on running time
my $runtime_seconds = $epoch_now - $start_epoch;
system("echo $viewer Running time: $runtime_seconds seconds >> $swamplog");
print $runtime_seconds;

my ($stat_epoch, $last_epoch) = find_last_tomcat_timestamp();
# if tomcat timestamp not found then either lastlog will be 0 
# (both last and start epochs are 0)
# or lastlog will be < 0
# in either case use stat mtime differece instead
my $lastlog_seconds = $last_epoch - $start_epoch;
if ($lastlog_seconds < $CHECKTIMEOUT_LASTLOG) {
	$lastlog_seconds = $epoch_now - $stat_epoch;
}
system("echo $viewer Time since last log: $lastlog_seconds seconds >> $swamplog");
print ' ', $lastlog_seconds;
