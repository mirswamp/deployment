#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

use strict;
use warnings;
use Log::Log4perl qw(:easy);
use Data::Dumper;
use Cwd;
use Getopt::Long;
use lib "/opt/swamp/perl5";
use SWAMP::AgentMonitorCommon;

my $debug = 0;
my $verbose = 0;

sub read_viewer_file {
	my $cwd = getcwd();
	chdir "/opt/swamp/run";
	SWAMP::AgentMonitorCommon::_restoreViewerState();
	chdir $cwd;
}

sub get_viewer_state { my ($vmname) = @_ ;
	my $dstate = '';
	my $vstate = '';
	(my $project, my $viewer, $dstate) = SWAMP::AgentMonitorCommon::getViewerByDomain($vmname);
	$dstate = '' if (! $dstate);
	$vstate = SWAMP::AgentMonitorCommon::getViewerState($viewer, $project) if ($viewer && $project);
	print "$vmname - dstate: $dstate vstate: $vstate\n";
}

sub show_viewer_file {
	print Dumper($SWAMP::AgentMonitorCommon::_viewers);
}

sub usage {
	print "usage: $0 [-help -debug -verbose] -vmname <string>\n";
	exit;
}

# usage() if (! @ARGV);

my $help = 0;
my $vmname;
my $result = GetOptions(
	'help'			=> \$help,
	'debug'			=> \$debug,
	'verbose'		=> \$verbose,
	'vmname=s'		=> \$vmname,
);
usage() if ($help || ! $result);
# usage() if (! $vmname);

Log::Log4perl::easy_init($DEBUG);
read_viewer_file();
get_viewer_state($vmname) if ($vmname);
show_viewer_file();
