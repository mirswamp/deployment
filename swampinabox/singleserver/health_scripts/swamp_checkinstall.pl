#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

use strict;
use warnings;
use POSIX qw(strftime);
use Log::Log4perl qw(:easy);

use FindBin qw($Bin);
use lib ("$Bin/../perl5", "$Bin/lib", "$Bin/../lib");
use SWAMP::vmu_Support qw(
	$global_swamp_config
	getSwampConfig
	database_connect
	database_disconnect
	systemcall
	rpccall
	from_json_wrapper
);
use SWAMP::vmu_AssessmentSupport qw(
	getLaunchExecrunuids
);

Log::Log4perl->easy_init($ERROR);
my $log = Log::Log4perl->get_logger(q{});

my $global_error_count = 0;

sub get_swamp_database_status {
	my $database_status;
	my $dbh = database_connect();
	if ($dbh) {
		my $query = q{SELECT now(), version(), database_version_no, description FROM assessment.database_version ORDER BY create_date DESC LIMIT 1};
		my @version_row = $dbh->selectrow_array($query);
		if ($dbh->err) {
			$log->error("get_swamp_database_status - $query error: ", $dbh->errstr);
			$database_status = undef;
		}
		database_disconnect($dbh);
		$database_status = (join ' ', @version_row);
	}
	else {
		$log->error("get_swamp_database_status - database connection failed");
	}

	my $execrunuids = getLaunchExecrunuids();
	my $queue_status;
	if ($execrunuids) {
		$queue_status = scalar(@$execrunuids);
	}
	my $result = 'Swamp database status: ';
	if (defined($database_status)) {
		$result .= $database_status;
	}
	else {
		$result .= 'undef';
		$global_error_count += 1;
	}
	$result .= "\n";
	$result .= 'Swamp database queue: ';
	if (defined($queue_status)) {
		$result .= $queue_status;
	}
	else {
		$result .= 'undef';
		$global_error_count += 1;
	}
	return $result;
}

sub get_condor_vm_status {
	my $command = 'condor_status -af Machine';
	my $vm_status;
	my ($output, $status) = systemcall($command);
	if ($status) {
		$log->error("get_condor_vm_status - $command status: $status output: $output");
	}
	else {
		my @tslots = split "\n", $output;
		my $tslots = scalar(@tslots);
		my $command = 'condor_status -vm -af Machine';
		my ($output, $status) = systemcall($command);
		if ($status) {
			$log->error("get_condor_vm_status - $command status: $status output: $output");
		}
		else {
			my @vmslots = split "\n", $output;
			my $vmslots = scalar(@vmslots);
			$vm_status = "$vmslots/$tslots";
		}
	}
	my $result = 'HTCondor vm status: ';
	if (defined($vm_status)) {
		$result .= $vm_status;
	}
	else {
		$result .= 'undef';
		$global_error_count += 1;
	}
	return $result;
}

sub _get_swamp_daemon_status { my ($daemon, $req) = @_ ;
	my $rpc_result;
	my $status = rpccall($daemon, $req);
	if ($status && $status->{'value'}) {
		$status = $status->{'value'};
		my $started_time = $status->{'started_int'};
		$started_time = strftime('%Y-%m-%d %H:%M:%S', localtime($started_time));
		my $methods = $status->{'methods_known'};
		my $host = $status->{'host'};
		my $port = $status->{'port'};
		my $requests = $status->{'total_requests'};
		$rpc_result = "$started_time $host $port methods: $methods requests: $requests";
	}
	return $rpc_result;
}

sub get_swamp_service_status {
	my $agent_monitor = RPC::XML::Client->new(SWAMP::vmu_Support::_configureAgentClient());
	my $req = RPC::XML::request->new('system.status');
	my $agent_monitor_status = _get_swamp_daemon_status($agent_monitor, $req);
	my $launchpad = RPC::XML::Client->new(SWAMP::vmu_Support::_configureLaunchPadClient());
	my $launchpad_status = _get_swamp_daemon_status($launchpad, $req);
	my $result = 'Swamp AgentMonitor service status: ';
	if (defined($agent_monitor_status)) {
		$result .= $agent_monitor_status;
	}
	else {
		$result .= 'undef';
		$global_error_count += 1;
	}
	$result .= "\n";
	$result .= 'Swamp LaunchPad service status: ';
	if (defined($launchpad_status)) {
		$result .= $launchpad_status;
	}
	else {
		$result .= 'undef';
		$global_error_count += 1;
	}
	return $result;
}

sub _get_curl_result { my ($swamp_api_web_server, $route) = @_ ;
	my $curl_result;
	my $url = $swamp_api_web_server . '/' . $route;
	my $command = "curl --silent --insecure -H 'Accept: application/json' --header \"Content-Length:0\" -X GET $url";
	my ($output, $status) = systemcall($command);
	$curl_result = $output;
	if ($status) {
		$log->error("$command failed - status: $status output: [$output]");
		$curl_result = undef;
	}
	if ($curl_result && $curl_result =~ m/exception/i) {
		$curl_result = undef;
	}
	return $curl_result;
}

sub get_swamp_web_status {
	my $swamp_environment_status; 
	my $swamp_platforms_list = [];
	my $swamp_tools_list = [];
	$global_swamp_config ||= getSwampConfig();
    my $swamp_api_web_server = $global_swamp_config->get('swamp_api_web_server');
    if (! $swamp_api_web_server) {
        $log->error("swamp_api_web_server not found");
    }   
    else {
        my $environment_route = 'environment';
		$swamp_environment_status = _get_curl_result($swamp_api_web_server, $environment_route);
		my $platforms_list_route = 'platforms/public';
		my $swamp_platforms_json = _get_curl_result($swamp_api_web_server, $platforms_list_route);
		if ($swamp_platforms_json) {
			my $aref = from_json_wrapper($swamp_platforms_json);
			if ($aref) {
				foreach my $platform (@$aref) {
					push @$swamp_platforms_list, $platform->{'name'} || 'undef';
				}
			}
		}
		my $tools_list_route = 'tools/public';
		my $swamp_tools_json = _get_curl_result($swamp_api_web_server, $tools_list_route);
		if ($swamp_tools_json) {
			my $aref = from_json_wrapper($swamp_tools_json);
			if ($aref) {
				foreach my $tool (@$aref) {
					push @$swamp_tools_list, $tool->{'name'} || 'undef';
				}
			}
		}
    }
	my $result = 'Swamp environment: ';
	if (defined($swamp_environment_status)) {
		$result .= $swamp_environment_status;
	}
	else {
		$result .= 'undef';
		$global_error_count += 1;
	}
	$result .= "\n";
	$result .= 'Swamp platforms list: ';
	$result .= (join ", ", @$swamp_platforms_list);
	if (scalar(@$swamp_platforms_list) <= 0) {
		$global_error_count += 1;
	}
	$result .= "\n";
	$result .= 'Swamp tools list: ';
	$result .= (join ", ", @$swamp_tools_list);
	if (scalar(@$swamp_tools_list) <= 0) {
		$global_error_count += 1;
	}
	return $result;
}

my $swamp_database_status = get_swamp_database_status();
print $swamp_database_status, "\n";
my $condor_vm_status = get_condor_vm_status();
print $condor_vm_status, "\n";
my $swamp_service_status = get_swamp_service_status();
print $swamp_service_status, "\n";
my $swamp_web_status = get_swamp_web_status();
print $swamp_web_status, "\n";
exit $global_error_count;
