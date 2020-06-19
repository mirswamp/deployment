#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

use strict;
use warnings;
use Time::Local;
use POSIX qw(strftime);

my $viewer;
my $tomcatlogdir;
my $swampstartlogfile = $ENV{'VIEWER_STARTEPOCH_FILE'};
my $swamplog = $ENV{'SWAMP_LOG_FILE'};

sub parse_date_to_epoch { my ($date, $format) = @_ ;
	# swamp 2016/06/03 11:19:08
	# tomcat access 07/Jun/2016:01:18:48 +0000
	# catalina 07-Jun-2016 HH:MM:SS
	my %months = (Jan=> 0, Feb=> 1, Mar=> 2, Apr=> 3, May=>4, Jun=> 5, Jul=> 6, Aug=> 7, Sep=> 8, Sep=> 8, Oct=> 9, Nov=> 10, Dec=> 11);
	my ($day, $month, $year, $time, $pm);
	if ($format eq 'swamp') {
		my @parts = split ' ', $date;
		(my $ymd, $time) = @parts;
		($year, $month, $day) = split '/', $ymd;
		$month -= 1;
	}
	elsif ($format eq 'tomcat') {
		(my $dmy, $time) = split ':', $date, 2;
		($time) = split ' ', $time;
		($day, $month, $year) = split '/', $dmy;
		$month = $months{$month};
	}
	elsif ($format eq 'catalina') {
		(my $dmy, $time) = split ' ', $date, 2;
		($day, $month, $year) = split '-', $dmy;
		$month = $months{$month};
	}
	my ($hour, $min, $sec) = split ':', $time;
	$hour += 12 if ($pm);
	return undef if (! defined($hour) || ! defined($min) || ! defined($sec));
	my $epoch = timelocal($sec, $min, $hour, $day, $month, $year);
	return $epoch;
}

sub find_vm_start_timestamp {
    if (open(my $fh, '<', $swampstartlogfile)) {
		my @lines = <$fh>;
		close($fh);
		foreach my $line (@lines) {
			chomp $line;
			if ($line =~ m/\d+/) {
				my $epoch = $line;
				return $epoch;
			}
		}
	}
	if (open(my $fh, '<', $swamplog)) {
		my @lines = <$fh>;
		close($fh);
		foreach my $line (@lines) {
			if ($line =~ m/^(.*):\s+.*\s+Starting $viewer viewer via run.sh$/) {
				my $date = $1;
				last if (! $date);
				my $epoch = parse_date_to_epoch($date, 'swamp');
				last if (! defined($epoch));
				return $epoch;
			}
		}
	}
	return 0;
}

sub find_last_catalina_timestamp { my ($logfile) = @_ ;
	my $epoch = 0;
	# get mtime from stat on tomcat log file
	my $stat_epoch = (stat $logfile)[9];
	if (open(my $fh, '<', $logfile)) {
		my @lines = <$fh>;
		close($fh);
		my @epochs = ();
		foreach my $line (@lines) {
            if ($line =~ m/(\d+-[A-Za-z]+-\d+\s+\d+:\d+:\d+).\d+\s+/) {
				my $date = $1;
				my $epoch = parse_date_to_epoch($date, 'catalina');
				push @epochs, $epoch if (defined($epoch));
			}
		}
		@epochs = reverse sort @epochs;
		$epoch = $epochs[0];
	}
	return ($stat_epoch, $epoch);
}

sub find_last_tomcat_activity { my ($logfile) = @_ ;
	my $epoch = 0;
	my $stat_epoch = (stat $logfile)[9];
	if (open(my $fh, '<', $logfile)) {
		my @lines = <$fh>;
		close($fh);
		my $line = $lines[-1];
		if ($line && $line =~ m/^.*\[(.*)\].*$/) {
			my $date = $1;
			if ($date) {
				$epoch = parse_date_to_epoch($date, 'tomcat');
			}
		}
	}
	return ($stat_epoch, $epoch);
}

sub find_last_tomcat_timestamp { my ($start_epoch) = @_ ;
	my ($stat_epoch, $last_epoch);
	my $tomcatlog = "$tomcatlogdir/localhost_access_log.txt";
	if (-r $tomcatlog) {
		($stat_epoch, $last_epoch) = find_last_tomcat_activity($tomcatlog);
	}
	my $date = strftime("%Y-%m-%d", localtime());
	$tomcatlog = "$tomcatlogdir/localhost_access_log.${date}.txt";
	if ((! defined($last_epoch)) && (-r $tomcatlog)) {
		($stat_epoch, $last_epoch) = find_last_tomcat_activity($tomcatlog);
	}
	$tomcatlog = "$tomcatlogdir/catalina.out";
	if ((! defined($last_epoch)) && (-r $tomcatlog)) {
		($stat_epoch, $last_epoch) = find_last_catalina_timestamp($tomcatlog);
	}
	return $last_epoch if ($last_epoch && ($last_epoch > 0));
	return $stat_epoch || $start_epoch;
}

sub stohms { my ($seconds) = @_ ;
	my $hms = strftime("%H:%M:%S", gmtime($seconds));
	return $hms;
}

$viewer = $ARGV[0] || 'CodeDX';
$tomcatlogdir = $ARGV[1] || '/opt/tomcat/logs';
my $CHECKTIMEOUT_LASTLOG = $ARGV[2] || 3600;
my $epoch_now = time();

my $start_epoch = find_vm_start_timestamp();
# if start_epoch not found then it will be 0 and runtime will be epoch_now
# this will cause vm to be permitted to shutdown based on running time
my $runtime_seconds = $epoch_now - $start_epoch;
my $runtime_hms = stohms($runtime_seconds);
system("echo $viewer Running time: $runtime_hms \\($runtime_seconds\\) >> $swamplog");
print $runtime_seconds;

my $last_epoch = find_last_tomcat_timestamp($start_epoch);
# if last_epoch not found then it will be start_epoch and lastlog will be runtime
my $lastlog_seconds = $epoch_now - $last_epoch;
my $lastlog_hms = stohms($lastlog_seconds);
system("echo $viewer Time since last log: $lastlog_hms \\($lastlog_seconds\\) >> $swamplog");

print ' ', $lastlog_seconds;
