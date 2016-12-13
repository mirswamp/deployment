#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

use strict;
use warnings;
use File::Spec;
use File::Copy;
use Date::Parse;

my $tracedir = '/opt/swamp/log';
my $tracefile = File::Spec->catfile($tracedir, 'viewertrace.log');
my $runoutfile;
my $timingfile;

sub parse_trace { my ($vmname) = @_ ;
	my @output_lines = ();
	my $fh;
	if (! open($fh, '<', $tracefile)) {
		print "Error - open $tracefile failed\n";
		exit;
	}
	my @lines = <$fh>;
	close($fh);
	my $execrunuuid;
	foreach my $line (@lines) {
		if ($line =~ m/vrun\.(.*).CodeDX $vmname Calling start_vm$/) {
			$execrunuuid = $1;
			last;
		}
	}
	if ($execrunuuid) {
		my @idlines = grep($execrunuuid, @lines);
		chomp @idlines;
		# find block of idlines that contains Start launchviewer .. 
		# $vmname Calling start_vm .. 
		# CodeDX launched successfully
		my @vmlines = ();
		my $foundvm = 0;
		foreach my $line (@idlines) {
			if ($line =~ m/Start launchviewer$/) {
				@vmlines = ();
				push @vmlines, $line;
			}
			elsif (@vmlines) {
				push @vmlines, $line;
				if ($line =~ m/CodeDX launched successfully$/) {
					last if ($foundvm);
				}
				elsif ($line =~ m/vrun.*CodeDX $vmname Calling start_vm$/) {
					$foundvm = 1;
				}
			}
		}
		push @output_lines, @vmlines;
	}
	return \@output_lines;
}

sub parse_run_out {
	my @output_lines = ();
	my $fh;
	if (! open($fh, '<', $runoutfile)) {
		print "Error - open $runoutfile failed\n";
		exit;
	}
	my @lines = <$fh>;
	close($fh);
	chomp @lines;
	foreach my $line (@lines) {
		push @output_lines, $line if ($line =~ m/Starting CodeDX viewer via run\.sh/);
		push @output_lines, $line if ($line =~ m/Starting mysql service$/);
		push @output_lines, $line if ($line =~ m/Service mysql running$/);
		push @output_lines, $line if ($line =~ m/Restoring CodeDX/);
		push @output_lines, $line if ($line =~ m/Starting tomcat service$/);
		push @output_lines, $line if ($line =~ m/Service tomcat running$/);
		push @output_lines, $line if ($line =~ m/CodeDX viewer is UP$/);
		push @output_lines, $line if ($line =~ m/Shutting down CodeDX via checktimeout$/);
	}
	return \@output_lines;
}

sub sort_output { my ($trace_lines, $run_lines) = @_ ;
	my @output_lines = ();
	my $done = 0;
	my $tline; my $rline;
	my $ttime; my $rtime;
	my ($start, $condor, $vm, $run, $mysql, $restore, $tomcat, $viewer, $launched);
	while (! $done) {
		if (! $tline) {
			# trace lines are in UTC
			$tline = shift @$trace_lines;
			if ($tline) {
				my ($tdate) = split ': ', $tline;
				# print "TL: <$tdate>", "\n";
				$ttime = str2time($tdate);
				# print $ttime, "\n";
				if ($tline =~ m/Start launchviewer$/) {
					$start = $ttime;
				}
				elsif ($tline =~ m/Calling condor_submit$/) {
					$condor = $ttime;
				}
				elsif ($tline =~ m/Calling start_vm$/) {
					$vm = $ttime;
				}
				elsif ($tline =~ m/launched successfully$/) {
					$launched = $ttime;
				}
			}
		}

		if (! $rline) {
			# run lines are in CDT
			$rline = shift @$run_lines;
			if ($rline) {
				my ($rdate) = split ': ', $rline;
				# print "RL: <$rdate>", "\n";
				$rtime = str2time($rdate);
				# print $rtime, "\n";
				if ($rline =~ m/via run\.sh$/) {
					$run = $rtime;
				}
				elsif ($rline =~ m/mysql running$/) {
					$mysql = $rtime;
				}
				elsif ($rline =~ m/from codedx.war$/) {
					$restore = $rtime;
				}
				elsif ($rline =~ m/tomcat running$/) {
					$tomcat = $rtime;
				}
				elsif ($rline =~ m/viewer is UP$/) {
					$viewer = $rtime;
				}
			}
		}

		if (! $tline && ! $rline) {
			$done = 1;
			next;
		}

		if (! $tline) {
			push @output_lines, $rline;
			$rline = '';
		}
		elsif (! $rline) {
			push @output_lines, $tline;
			$tline = '';
		}
		elsif ($ttime < $rtime) {
			push @output_lines, $tline;
			$tline = '';
		}
		else {
			push @output_lines, $rline;
			$rline = '';
		}
	}
	my @sorted_lines = ();
	# my ($start, $condor, $vm, $run, $mysql, $restore, $tomcat, $viewer, $launched);
	foreach my $line (@output_lines) {
		if ($line =~ m/launched successfully$/) {
			push @sorted_lines, $line . ' (' . ($launched - $viewer) . ') [' . ($launched - $start) . ']';
		}
		elsif ($line =~ m/viewer is UP$/) {
			push @sorted_lines, $line . ' (' . ($viewer - $tomcat) . ') {' . ($viewer - $run) . '} [' . ($viewer - $start) . ']';
		}
		elsif ($line =~ m/tomcat running$/) {
			push @sorted_lines, $line . ' (' . ($tomcat - $restore) . ') [' . ($tomcat - $start) . ']';
		}
		elsif ($line =~ m/from codedx.war$/) {
			push @sorted_lines, $line . ' (' . ($restore - $mysql) . ') [' . ($restore - $start) . ']';
		}
		elsif ($line =~ m/mysql running$/) {
			push @sorted_lines, $line . ' (' . ($mysql - $run) . ') [' . ($mysql - $start) . ']';
		}
		elsif ($line =~ m/via run\.sh/) {
			push @sorted_lines, $line . ' (' . ($run - $vm) . ') [' . ($run - $start) . ']';
		}
		elsif ($line =~ m/Calling start_vm$/) {
			push @sorted_lines, $line . ' (' . ($vm - $condor) . ') [' . ($vm - $start) . ']';
		}
		elsif ($line =~ m/Calling condor_submit$/) {
			push @sorted_lines, $line . ' [' . ($condor - $start) . ']';
		}
		else {
			push @sorted_lines, $line;
		}
	}
	return \@sorted_lines;
}

sub vmExists { my ($vmname) = @_ ;
	my $result = `virsh list --all | grep $vmname`;
    return 'running' if ($result =~ m/running/);
    return 'not running'  if ($result);
    return undef;
}

sub fetch_run_out { my ($vmname) = @_ ;
	my $state = vmExists($vmname);
	if ($state) {
    	my $result = `virt-copy-out -d $vmname -m /dev/sdc:/mnt/out /mnt/out/run.out /opt/swamp/log`;
		chomp $result;
		print "virt-copy-out $vmname result: <$result>\n";
		if (! $result) {
			move('/opt/swamp/log/run.out', $runoutfile);
		}
	}
	else {
		print "Shutdown $vmname not found\n";
	}
}

sub write_output { my ($sorted_lines) = @_ ;
	my $fh;
	if (! open($fh, '>', $timingfile)) {
		print "Error - open $timingfile failed\n";
		exit;
	}
	print $fh join "\n", @$sorted_lines;
	print $fh "\n";
	close($fh);
	print join "\n", @$sorted_lines;
	print "\n";
}

my $vmname = $ARGV[0] if (defined($ARGV[0]));
if (! $vmname) {
	print "Error - vmname required\n";
	exit;
}
$runoutfile = "/opt/swamp/log/$vmname-run.out";
$timingfile = "/opt/swamp/log/$vmname-timing.out";

fetch_run_out($vmname) if (! -r $runoutfile);
my $trace_lines = parse_trace($vmname);
my $run_lines = parse_run_out();
my $sorted_lines = sort_output($trace_lines, $run_lines);
write_output($sorted_lines);

print "Hello World!\n";
