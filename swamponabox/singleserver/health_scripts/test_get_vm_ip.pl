#!/usr/bin/env perl
use utf8;
use warnings;
use strict;
use 5.010;

use English qw( -no_match_vars );
use File::Basename qw(basename);
use Log::Log4perl;
use SWAMP::Libvirt qw(getVMIPAddress);
use SWAMP::vmu_Support qw(
  getLoggingConfigString
  getSwampConfig
);

#
# Set up logging.
#
my $program_name = basename($PROGRAM_NAME, ('.pl'));

sub logfilename { return "${program_name}.log"; }
sub logtag      { return "${program_name}"; }

Log::Log4perl->init(getLoggingConfigString());

#
# Query for the given VM's IP address.
#
my $vm_name = $ARGV[0] || 'unknown';
my $config  = getSwampConfig();
my $log     = Log::Log4perl->get_logger(q{});

$log->info("Checking for: $vm_name");

print getVMIPAddress($config, $vm_name) . "\n";
