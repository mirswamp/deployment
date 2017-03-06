#!/usr/bin/env perl
use strict;
use warnings;
use Log::Log4perl qw(:easy);
use Getopt::Long;
use HTCondorClassAds qw(
	get_condor_collector_host
	show_collector_records
);
use lib '/opt/swamp/perl5';
use SWAMP::vmu_Support qw(getSwampConfig systemcall);

my $help	= 0;
my $debug	= 0;
my $verbose	= 0;
my $quiet	= 0;

Log::Log4perl->easy_init($verbose ? ($quiet ? $OFF : $DEBUG) : $OFF);
my $hostname = `hostname`; chomp $hostname;

sub get_condor_submit_node {
	my $command = "condor_status -schedd -af Name";
	my ($output, $status) = systemcall($command);
	if ($status) {
		print "Error - $command failed - status: $status output: $output\n" if (! $quiet);
		return;
	}
	chomp $output;
	return $output;
}

sub get_condor_exec_nodes {
	my $command = "condor_status -af Machine -constraint 'SlotType == \"Partitionable\"'";
	my ($output, $status) = systemcall($command);
	if ($status) {
		print "Error - $command failed - status: $status output: $output\n" if (! $quiet);
		return;
	}
	my @execnodes = split "\n", $output;
	return \@execnodes;
}

sub get_swamp_data_node {
	my $data_node;
	my $config = getSwampConfig();                                                                                
	if ($config) {
		$data_node = $config->get('quartermasterHost');
		if ($data_node eq 'localhost') {
			$data_node = $hostname;
		}
	}
	return $data_node;
}

sub show_swamp_processes { my ($host) = @_ ;
	return if (! $host);
	my $command = "ps aux | egrep 'PID|vmu_|java' | grep -v grep";
	if ($host ne $hostname) {
		$command = "ssh $host ps aux | egrep 'vmu_|java' | grep -v grep";
	}
	my ($output, $status) = systemcall($command);
	if ($status) {
		print "Error - $command failed - status: $status output: $output\n" if (! $quiet);
		return;
	}
	my @lines = split "\n", $output;
	my $fields = "";
	my $vmuA = [];
	my $vmuV = [];
	my $vmu = [];
	my $java = [];
	my $other = [];
	foreach my $line (@lines) {
		if ($line =~ m/PID/) {
			$fields = $line;
		}
		elsif ($line =~ m/vmu_.*Assessment/) {
			push @$vmuA, $line;
		}
		elsif ($line =~ m/vmu_.*Viewer/) {
			push @$vmuV, $line;
		}
		elsif ($line =~ m/vmu_.*.pl/) {
			push @$vmu, $line;
		}
		elsif ($line =~ m/java/) {
			push @$java, $line;
		}
		else {
			push @$other, $line;
		}
	}
	# sort vmuA and vmuV on clusterid at end of COMMAND field
	@$vmuA = sort {
		my @aparts = split ' ', $a; 
		# either clusterid procid or clusterid procid debug
		# 		 -2        -1        -3        -2     -1
		my $acmp = $aparts[-2];
		$acmp = $aparts[-3] if ($aparts[-1] !~ m/^\d+$/);
		my @bparts = split ' ', $b; 
		my $bcmp = $bparts[-2];
		$bcmp = $bparts[-3] if ($bparts[-1] !~ m/^\d+$/);
		if (($acmp =~ m/^\d+$/) && ($bcmp =~ m/^\d+$/)) {
			return $acmp <=> $bcmp;
		}
		else {
			return $acmp cmp $bcmp;
		}
	} @$vmuA;
	@$vmuV = sort {
		my @aparts = split ' ', $a; 
		# either clusterid procid or clusterid procid debug
		# 		 -2        -1        -3        -2     -1
		my $acmp = $aparts[-2];
		$acmp = $aparts[-3] if ($aparts[-1] !~ m/^\d+$/);
		my @bparts = split ' ', $b; 
		my $bcmp = $bparts[-2];
		$bcmp = $bparts[-3] if ($bparts[-1] !~ m/^\d+$/);
		if (($acmp =~ m/^\d+$/) && ($bcmp =~ m/^\d+$/)) {
			return $acmp <=> $bcmp;
		}
		else {
			return $acmp cmp $bcmp;
		}
	} @$vmuV;
	my $header = "vmu_ and java processes on $host";
	# discount fields line in count
	$header .= " T:[" . (scalar(@lines)-1) . "]";
	$header .= " A:[" . (scalar(@$vmuA)) . "]";
	$header .= " V:[" . (scalar(@$vmuV)) . "]";
	$header .= " v:[" . (scalar(@$vmu)) . "]";
	$header .= " j:[" . (scalar(@$java)) . "]";
	$header .= " o:[" . (scalar(@$other)) . "]";
	print $header, "\n";
	my $under = "-" x length($header);
	print $under, "\n";
	print $fields, "\n";
	if (@$vmuA || @$vmuV) {
		print $_, "\n" foreach (@$vmuA);
		print $_, "\n" foreach (@$vmuV);
	}
	if (@$vmu) {
		print "\n";
		print $_, "\n" foreach (@$vmu);
	}
	if (@$java) {
		print "\n";
		print $_, "\n" foreach (@$java);
	}
	if (@$other) {
		print "\n";
		print $_, "\n" foreach (@$other);
	}
}

sub show_condor_queue { my ($submit_node) = @_ ;
	return if (! $submit_node);
	print "Condor Queue\n";
	print "------------";
	my $command = "condor_q -pool $submit_node";
	my ($output, $status) = systemcall($command);
	if ($status) {
		print "Error - $command failed - status: $status output: $output\n" if (! $quiet);
		return;
	}
	if (! $output) {
		print "no condor records\n" if (! $quiet);
		return;
	}
	print $output, "\n";
}

sub show_virtual_machines { my ($exec_node) = @_ ;
	return if (! $exec_node);
	my $command = "virsh list --all";
	if ($exec_node ne $hostname) {
		$command = "ssh $exec_node virsh list --all";
	}
	my ($output, $status) = systemcall($command);
	if ($status) {
		print "Error - $command failed - status: $status output: $output\n" if (! $quiet);
		return;
	}
	my @vms = grep(! m/Id|\-\-/, split "\n", $output);
	# sort vm list on name field with condor clusterid_procid suffix
	@vms = sort {my @aparts = split ' ', $a; my @bparts = split ' ', $b; $aparts[1] cmp $bparts[1];} @vms;
	print $exec_node, " [", scalar(@vms), "]\n";
	foreach my $vm (@vms) {
		print "  ", $vm, "\n";
	}
}

sub show_submit_rundir { my ($submit_node) = @_ ;
	return if (! $submit_node);
	my $command = "ls -lrt /opt/swamp/run";
	if ($submit_node ne $hostname) {
		$command = "ssh $submit_node ls -lrt /opt/swamp/run";
	}
	my ($output, $status) = systemcall($command);
	if ($status) {
		print "Error - $command failed - status: $status output: $output\n" if (! $quiet);
		return;
	}
	if (! $output) {
		print "no contents in /opt/swamp/run\n";
		return;
	}
	my @lines = grep(! m/swamp_monitor|total/, split "\n", $output);
	my $header = "SWAMP Submit Run Directory:"; 
	print $header, " [" . scalar(@lines) . "]", "\n";
	print '-' x length($header), "\n";
	foreach my $line (@lines) {
		my $clusterid = '';
		my $dir = (split ' ', $line)[-1];
		my $cfile = (glob("/opt/swamp/run/$dir/ClusterId*"))[0];
		if ($cfile) {
			$clusterid = (split '_', $cfile)[-1];
		}
		print $line, ' ', $clusterid, "\n";
	}
	print "\n";
}

sub usage {
	print "usage: $0 [-help -debug -verbose -quiet -sleep <integer> -condor -collector|[-assess|-viewer] -rundir -libvirt -swamp|[-data|-sub|-exec]]\n";
	exit;
}

my ($condor, $collector, $assess, $viewer, $rundir, $libvirt, $swamp, $data, $sub, $exec);
my $sleep = 0;
my $result = GetOptions(
	'help'      => \$help,
	'debug'     => \$debug,
	'verbose'   => \$verbose,
	'quiet'		=> \$quiet,
	'sleep=i'	=> \$sleep,
	'condor'	=> \$condor,
	'collector'	=> \$collector,
	'assess'	=> \$assess,
	'viewer'	=> \$viewer,
	'rundir'	=> \$rundir,
	'libvirt'	=> \$libvirt,
	'swamp'		=> \$swamp,
	'data'		=> \$data,
	'sub'		=> \$sub,
	'exec'		=> \$exec,
);
usage() if ($help || ! $result);    
my $all = ! $condor && ! $collector && ! $assess && ! $viewer && ! $rundir && ! $libvirt && ! $swamp && ! $data && ! $sub && !$exec;

my $HTCONDOR_COLLECTOR_HOST = get_condor_collector_host();
my $submit_node = get_condor_submit_node();
my $exec_nodes = get_condor_exec_nodes();
my $data_node = get_swamp_data_node();

if ($debug) {
	print "collector: ", $HTCONDOR_COLLECTOR_HOST || "", "\n";
	print "submit: ", $submit_node || "", "\n";
	print "exec: ", @$exec_nodes || "", "\n";
	print "data: ", $data_node || "", "\n";
	print "\n";
}

while (1) {
	system("clear") if ($sleep);
	show_condor_queue($submit_node) if ($all || $condor);
	show_collector_records($HTCONDOR_COLLECTOR_HOST, 'assessment', 1) if ($all || $collector || $assess);
	show_collector_records($HTCONDOR_COLLECTOR_HOST, 'viewer', 0) if ($all || $collector || $viewer);
	show_submit_rundir($submit_node) if ($all || $rundir);
	if ($all || $libvirt) {
		if ($all) {
			print "Virsh List [", scalar(@$exec_nodes), "]\n";
			print "----------\n";
		}
		foreach my $exec_node (@$exec_nodes) {
			next if ($libvirt && ($exec_node ne $hostname));
			show_virtual_machines($exec_node) 
		}
	}
	my $seen = {};
	if ($all || $swamp || $sub) {
		show_swamp_processes($submit_node);
		$seen->{$submit_node} = 1 if ($submit_node);
	}
	if ($all || $swamp || $exec) {
		foreach my $exec_node (@$exec_nodes) {
			next if ($exec && ($exec_node ne $hostname));
			if (! $seen->{$exec_node}) {
				show_swamp_processes($exec_node);
				$seen->{$exec_node} = 1 if ($exec_node);
			}
		}
	}
	if ($all || $swamp || $data) {
		if ($data_node && ! $seen->{$data_node}) {
			show_swamp_processes($data_node) 
		}
	}
	last if (! $sleep);
	sleep $sleep;
}
