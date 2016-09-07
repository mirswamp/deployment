#!/usr/bin/env perl
use strict;
use warnings;
use Log::Log4perl qw(:easy);
use Data::Dumper;
use lib '/opt/swamp/perl5';
use SWAMP::vmu_Support qw(getSwampConfig systemcall);

Log::Log4perl->easy_init($OFF);

my $config = getSwampConfig();
my $HTCONDOR_COLLECTOR_HOST = $config->get('htcondor_collector_host');
my $command = qq{condor_status -pool $HTCONDOR_COLLECTOR_HOST -any -af:V, Name SWAMP_vmu_viewer_state SWAMP_vmu_viewer_status SWAMP_vmu_viewer SWAMP_vmu_viewer_vmip SWAMP_vmu_viewer_apikey SWAMP_vmu_viewer_project SWAMP_vmu_viewer_instance_uuid SWAMP_vmu_viewer_url_uuid -constraint \"isString(SWAMP_vmu_viewer_status)\"};
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
	my ($execrunuid, $state, $vstatus, $viewer, $vmip, $apikey, $project, $viewer_instance_uuid, $viewer_url_uuid) = @parts;
	print "execrunuid: $execrunuid\n";
	print "  state: $state\n";
	print "  status: $vstatus\n";
	print "  viewer: $viewer\n";
	print "  vmip: $vmip\n";
	print "  apikey: $apikey\n";
	print "  project: $project\n";
	print "  viewer_instance_uuid: $viewer_instance_uuid\n";
	print "  viewer_url_uuid: $viewer_url_uuid\n";
	print "\n";
}
print "Hello World!\n";
