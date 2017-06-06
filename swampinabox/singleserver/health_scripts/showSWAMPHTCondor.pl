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
my $html	= 0;

Log::Log4perl->easy_init($verbose ? ($quiet ? $OFF : $DEBUG) : $OFF);
my $hostname = `hostname`; chomp $hostname;
my $username = `whoami`; chomp $username;

sub newline {
	if ($html) {
		return "</br>";
	}
	else {
		return "\n";
	}
}

sub get_swamp_web_node {
	my $web_node = '';
	return $web_node;
}

sub get_swamp_directory_node {
	my $directory_node = '';
	return $directory_node;
}

sub get_swamp_data_node {
	my $data_node = '';
	my $config = getSwampConfig();
	if ($config) {
		$data_node = $config->get('quartermasterHost');
		if ($data_node eq 'localhost') {
			$data_node = $hostname;
		}
	}
	return $data_node;
}

sub get_swamp_condor_node {
	my $condor_node = '';
	return $condor_node;
}

sub get_condor_submit_node {
	my $submit_node = '';
	my $command = "condor_status -schedd -af Name";
	my ($output, $status) = systemcall($command);
	if ($status) {
		print "Error - $command failed - status: $status output: $output", newline() if (! $quiet);
		return $submit_node;
	}
	chomp $output;
	$submit_node = $output;
	return $submit_node;
}

sub get_condor_exec_nodes {
	my @exec_nodes = ();
	my $command = "condor_status -af Machine -constraint 'SlotType == \"Partitionable\"'";
	my ($output, $status) = systemcall($command);
	if ($status) {
		print "Error - $command failed - status: $status output: $output", newline() if (! $quiet);
		return \@exec_nodes;
	}
	@exec_nodes = split "\n", $output;
	return \@exec_nodes;
}

sub show_swamp_processes { my ($host) = @_ ;
	return if (! $host);
	my $command = "ps aux | egrep 'PID|vmu_|java' | grep -v grep";
	if ($host ne $hostname) {
		$command = "ssh $host ps aux | egrep 'vmu_|java' | grep -v grep";
	}
	my ($output, $status) = systemcall($command);
	if ($status) {
		print "Error - $command failed - status: $status output: $output", newline() if (! $quiet);
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
	print $header, newline();
	my $under = "-" x length($header);
	print $under, newline();
	print $fields, newline();
	if (@$vmuA || @$vmuV) {
		print $_, newline() foreach (@$vmuA);
		print $_, newline() foreach (@$vmuV);
	}
	if (@$vmu) {
		print newline();
		print $_, newline() foreach (@$vmu);
	}
	if (@$java) {
		print newline();
		print $_, newline() foreach (@$java);
	}
	if (@$other) {
		print newline();
		print $_, newline() foreach (@$other);
	}
}

sub show_condor_queue { my ($submit_node) = @_ ;
	return if (! $submit_node);
	print "Condor Queue", newline();
	print "------------", newline();
	# my $command = "condor_q -pool $submit_node";
	my $command = "ssh $submit_node condor_q";
	my ($output, $status) = systemcall($command);
	if ($status) {
		print "Error - $command failed - status: $status output: $output", newline() if (! $quiet);
		return;
	}
	if (! $output) {
		print "no condor records", newline() if (! $quiet);
		return;
	}
	chomp $output;
	print $output, newline();
}

sub show_virtual_machines { my ($exec_node) = @_ ;
	return if (! $exec_node);
	my $command = "virsh list --all";
	if ($exec_node ne $hostname) {
		$command = "ssh $exec_node virsh list --all";
	}
	my ($output, $status) = systemcall($command);
	if ($status) {
		print "Error - $command failed - status: $status output: $output", newline() if (! $quiet);
		return;
	}
	my @vms = grep(! m/Id|\-\-/, split "\n", $output);
	# sort vm list on name field with condor clusterid_procid suffix
	@vms = sort {my @aparts = split ' ', $a; my @bparts = split ' ', $b; $aparts[1] cmp $bparts[1];} @vms;
	print $exec_node, " [", scalar(@vms), "]", newline();
	foreach my $vm (@vms) {
		print "  ", $vm, newline();
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
		print "Error - $command failed - status: $status output: $output", newline() if (! $quiet);
		return;
	}
	if (! $output) {
		print "no contents in /opt/swamp/run", newline();
		return;
	}
	my @lines = grep(! m/swamp_monitor|total|.bog$/, split "\n", $output);
	my $header = "SWAMP Submit Run Directory:"; 
	print $header, " [" . scalar(@lines) . "]", newline();
	print '-' x length($header), newline();
	foreach my $line (@lines) {
		my $clusterid = '';
		my $dir = (split ' ', $line)[-1];
		my $cfile = (glob("/opt/swamp/run/$dir/ClusterId*"))[0];
		if ($cfile) {
			$clusterid = (split '_', $cfile)[-1];
		}
		print $line, ' ', $clusterid, newline();
	}
	print newline();
}

sub usage {
	print "usage: $0 [-help -debug -verbose -quiet -html -sleep <integer> -environment [dd|dt|it|pd|nn] -condor -collector|[-assess|-viewer] -rundir -libvirt -swamp|[-data|-sub|-exec]]", newline();
	exit;
}

my $environment;
my ($condor, $collector, $assess, $viewer, $rundir, $libvirt, $swamp, $data, $sub, $exec);
my $sleep = 0;

my $result = GetOptions(
	'help'      	=> \$help,
	'debug'     	=> \$debug,
	'verbose'   	=> \$verbose,
	'quiet'			=> \$quiet,
	'html'			=> \$html,
	'sleep=i'		=> \$sleep,
	'environment=s'	=> \$environment,
	'condor'		=> \$condor,
	'collector'		=> \$collector,
	'assess'		=> \$assess,
	'viewer'		=> \$viewer,
	'rundir'		=> \$rundir,
	'libvirt'		=> \$libvirt,
	'swamp'			=> \$swamp,
	'data'			=> \$data,
	'sub'			=> \$sub,
	'exec'			=> \$exec,
);
usage() if ($help || ! $result);    
my $all = ! $condor && ! $collector && ! $assess && ! $viewer && ! $rundir && ! $libvirt && ! $swamp && ! $data && ! $sub && !$exec;

my ($HTCONDOR_COLLECTOR_HOST, $web_node, $directory_node, $data_node, $condor_node, $submit_node, $exec_nodes);
if (! $environment) {
	$HTCONDOR_COLLECTOR_HOST = get_condor_collector_host();
	$web_node = get_swamp_web_node();
	$directory_node = get_swamp_directory_node();
	$data_node = get_swamp_data_node();
	$condor_node = get_swamp_condor_node();
	$submit_node = get_condor_submit_node();
	$exec_nodes = get_condor_exec_nodes();
}
else {
	if ($environment eq 'dd' || $environment eq 'dt' || $environment eq 'it' || $environment eq 'pd') {
		my $external_domain = 'cosalab.org';
		my $internal_domain = 'mirsam.org';
		$HTCONDOR_COLLECTOR_HOST = "swa-csacol-$environment-01.$external_domain";
		$web_node = "swa-csaweb-$environment-01.$internal_domain";
		$directory_node = "swa-dir-$environment-01.$internal_domain";
		$data_node = "swa-csadata-$environment-01.$internal_domain";
		$condor_node = "swa-csacon-$environment-01.$internal_domain";
		$submit_node = "swa-csasub-$environment-01.$internal_domain";
		if ($environment eq 'dd') {
			$exec_nodes = ["swa-exec-$environment-01.$internal_domain"];
		}
		elsif ($environment eq 'dt') {
			$data_node = "swa-csaper-$environment-01.$internal_domain";
			$exec_nodes = [];
			foreach my $nn ('04', '05') {
				push @$exec_nodes, "swa-exec-$environment-$nn.$internal_domain";
			}
		}
		elsif ($environment eq 'it') {
			$exec_nodes = [];
			foreach my $nn ('01', '02') {
				push @$exec_nodes, "swa-exec-$environment-$nn.$internal_domain";
			}
		}
		elsif ($environment eq 'pd') {
			$exec_nodes = [];
			foreach my $nn ('01', '02', '03', '04', '05', '06') {
				push @$exec_nodes, "swa-exec-$environment-$nn.$internal_domain";
			}
		}
	}
	elsif ($environment =~ m/^\d{2}$/) {
		my $host = "swa-exec-dt-$environment";
		$HTCONDOR_COLLECTOR_HOST = $host;
		$web_node = $host;
		$directory_node = $host;
		$data_node = $host;
		$condor_node = $host;
		$submit_node = $host;
		$exec_nodes = [$host];
	}
	else {
		usage();
	}
}

if ($debug) {
	print "hostname: ", $hostname || "", newline();
	print "username: ", $username || "", newline();
	print "environment: ", $environment || "", newline();
	print newline();
	print "collector: ", $HTCONDOR_COLLECTOR_HOST || "", newline();
	print "web: ", $web_node || "", newline();
	print "directory: ", $directory_node || "", newline();
	print "data: ", $data_node || "", newline();
	print "condor: ", $condor_node || "", newline();
	print "submit: ", $submit_node || "", newline();
	print "exec: ", (join ', ', @$exec_nodes) || "", newline();
	print newline();
}

while (1) {
	system("clear") if ($sleep);
	show_condor_queue($submit_node) if ($all || $condor);
	if ($all || $collector || $assess) {
		show_collector_records($HTCONDOR_COLLECTOR_HOST, 'assessment', 1, newline(), $submit_node);
	}
	if ($all || $collector || $viewer) {
		show_collector_records($HTCONDOR_COLLECTOR_HOST, 'viewer', 0, newline(), $submit_node);
	}
	show_submit_rundir($submit_node) if ($all || $rundir);
	if ($all || $libvirt) {
		if ($all) {
			print "Virsh List [", scalar(@$exec_nodes), "]", newline();
			print "----------", newline();
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
