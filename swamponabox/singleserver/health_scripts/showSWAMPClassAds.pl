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

my @assessment_fields = qw(
	Name 
	SWAMP_vmu_assessment_status
);
my $assessment_constraint = qq{-constraint \"isString(SWAMP_vmu_assessment_status)\"};

my @viewer_fields = qw(
	Name 
	SWAMP_vmu_viewer_name
	SWAMP_vmu_viewer_state 
	SWAMP_vmu_viewer_status 
	SWAMP_vmu_viewer_vmip 
	SWAMP_vmu_viewer_project 
	SWAMP_vmu_viewer_instance_uuid 
	SWAMP_vmu_viewer_apikey 
	SWAMP_vmu_viewer_url_uuid
);
my $viewer_constraint = qq{-constraint \"isString(SWAMP_vmu_viewer_status)\"};

sub show_collector_records { my ($title, $fields, $constraint) = @_ ;
	my $command = qq{condor_status -pool $HTCONDOR_COLLECTOR_HOST -any -af:V, };
	foreach my $field (@$fields) {
		$command .= ' ' . $field;
	}
	$command .= ' ' . $constraint if ($constraint);
	my ($output, $status) = systemcall($command);
	if ($status) {
		print "Error - condor_status $HTCONDOR_COLLECTOR_HOST show $title records failed - status: $status output: $output\n";
		return;
	}
	if (! $output) {
		print "no $title records\n";
		return;
	}
# print "output: $output\n";
	my @lines = split "\n", $output;
	foreach my $line (@lines) {
# print "$line\n";
		my @parts = split ',', $line;
		s/\"//g for @parts;
		s/^\s+//g for @parts;
		s/\s+$//g for @parts;
		print "execrunuid: $parts[0]\n";
		for (my $i = 1; $i < scalar(@parts); $i++) {
			my $field_name = $fields->[$i];
			$field_name =~ s/^SWAMP_vmu_${title}_//;
			print "  $field_name: ", $parts[$i], "\n";
		}
		print "\n";
	}
}

show_collector_records('assessment', \@assessment_fields, $assessment_constraint);
show_collector_records('viewer', \@viewer_fields, $viewer_constraint);

print "Hello World!\n";
