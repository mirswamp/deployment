#!/usr/bin/env perl
use strict;
use warnings;
use Log::Log4perl qw(:easy);
use Data::Dumper;
use lib '/opt/swamp/perl5';
use SWAMP::vmu_Support qw(getSwampConfig systemcall);

Log::Log4perl->easy_init($INFO);

my $config = getSwampConfig();
my $HTCONDOR_COLLECTOR_HOST = $config->get('htcondor_collector_host');
my $command = qq{condor_status -pool $HTCONDOR_COLLECTOR_HOST -any -af:V, Name SWAMP_vmu_assessment_status -constraint \"isString(SWAMP_vmu_assessment_status)\"};
my ($output, $status) = systemcall($command);
if ($status) {
	print "Error - condor_status $HTCONDOR_COLLECTOR_HOST failed - status: $status output: $output\n";
	exit;
}
if (! $output) {
	print "condor_status - no records\n";
	exit;
}
# print "output: $output\n";
my @lines = split "\n", $output;
foreach my $line (@lines) {
	# print "$line\n";
	my @parts = split ',', $line;
	s/\"//g for @parts;
	s/^\s+//g for @parts;
	s/\s+$//g for @parts;
	my ($execrunuid, $astatus) = @parts;
	print "execrunuid: $execrunuid\n";
	print "  status: $astatus\n";
	print "\n";
}
print "Hello World!\n";
