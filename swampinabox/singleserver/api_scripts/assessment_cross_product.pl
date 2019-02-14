#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

use strict;
use warnings;
use Getopt::Long;
use JSON;
use URI::Escape;
use Term::ReadLine;
use IO::Prompt;

my $debug				= 0;
my $verbose				= 0;
my $noexecute			= 0;
my $quiet				= 0;
my $commercial_tools	= 0;
my $global_packagecount	= 1;

# Terminal
my $term = new Term::ReadLine($0);

# SWAMP server
my $swampserver;

# login credentials
my $username;
my $password;

# api route prefix
my $api_route_prefix;

# current project
my $global_current_project = {};

# hash of package lists keyed on package_type_id
my $global_package_set = 'curated';
my $global_curated_packages = {};
my $global_user_packages = {};
my $global_package_type_id_to_tool_uuids = {}; # nested hash
my $global_name_to_package_type_id = {};
my $global_package_type_id_to_name = {};

# hash of platform version lists keyed on platform_uuid
my $global_platforms = {};
my $global_name_to_platform_version_uuid = {};
my $global_platform_version_uuid_to_name = {};

# hash of tool version lists keyed on package_type_id
my $global_tools_by_package_type_id = {};
my $global_all_tools = {};
my $global_tool_uuid_to_package_type_ids = {}; # nested hash
my $global_name_to_tool_uuid = {};
my $global_tool_uuid_to_name = {};

sub trim { my ($string) = @_ ;
	$string =~ s/^\s+|\s+$//g;
	return $string;
}

# determine api route prefix
sub set_api_route_prefix { my ($swampserver) = @_ ;
	if ($swampserver eq 'dd') {
		$swampserver = 'dd.cosalab.org';
	}
	elsif ($swampserver eq 'dt') {
		$swampserver = 'dt.cosalab.org';
	}
	elsif ($swampserver eq 'it') {
		$swampserver = 'it.cosalab.org';
	}
	elsif ($swampserver eq 'pd') {
		$swampserver = 'www.mir-swamp.org';
	}
	elsif ($swampserver =~ m/^dt-\d+$/) {
		$swampserver = 'swa-exec-' . $swampserver . '.mirsam.org';
	}
	my $api_route_prefix = "https://$swampserver";
	my $curl = "curl -s --insecure $api_route_prefix/config/config.json";
	print "curl command: <$curl>\n" if ($debug);
	my $result = `$curl`;
	my $config = {};
	if ($result) {
		eval {
			$config = from_json($result);
		};
		if ($@) {
			return;
		}
		$api_route_prefix = $config->{'servers'}->{'web'};
	}
	print "api_route_prefix: $api_route_prefix\n" if ($debug);
	return ($api_route_prefix, $swampserver);
}

# login
sub login { my ($username, $password) = @_ ;
	$password = uri_escape($password);
	my $curl = "curl -s --insecure -X POST -c cookies.txt --data \"username=${username}\&password=${password}\" $api_route_prefix/login";
	my $result = '{}';
	if (! $noexecute) {
		$result = `$curl`;
		print "login result: $result\n" if ($debug);
	}
	my $user = {};
	if ($result) {
		eval {
			$user = from_json($result);
		};
		if ($@) {
			if ($result =~ m/\<h1\>(.*)\<\/h1\>/) {
				$result = $1;
			}
			return ($result, undef);
		}
	}
	if (exists($user->{'user_uid'})) {
		return (undef, $user->{'user_uid'});
	}
	return ($result, undef);
}

# fetch projects for user
sub fetch_projects { my ($user_uuid) = @_ ;
	my $curl = "curl -s --insecure -X GET -b cookies.txt $api_route_prefix/users/$user_uuid/projects";
	my $result = `$curl`;
	my $projects = from_json($result);
	print "project count: ", scalar(@$projects), "\n" if ($verbose);
	return $projects;
}

# fetch package types
sub fetch_package_types {
	my $curl = "curl -s --insecure -X GET -b cookies.txt $api_route_prefix/packages/types";
	my $result = `$curl`;
	my $package_types = from_json($result);
	foreach my $package_type (@$package_types) {
		my $package_type_name = $package_type->{'name'};
		my $package_type_id = $package_type->{'package_type_id'};
		$global_name_to_package_type_id->{$package_type_name} = $package_type_id;
		$global_package_type_id_to_name->{$package_type_id} = $package_type_name;
		print $package_type_id, ') ', $package_type_name, "\n" if ($debug);
	}
}

# fetch packages - public curated or user packages
sub fetch_packages { my ($user_uuid) = @_ ;
	my $curl = "curl -s --insecure -X GET -b cookies.txt $api_route_prefix/packages/public";
	if ($user_uuid) {
		$curl = "curl -s --insecure -X GET -b cookies.txt $api_route_prefix/packages/users/$user_uuid";
	}
	my $result = `$curl`;
	my $packages = from_json($result);
	my $package_type_ids = {};
	foreach my $package (@$packages) {
		my $package_type_id = $package->{'package_type_id'};
		# exclude packages whose package_type is not enabled
		next if (! exists($global_package_type_id_to_name->{$package_type_id}));
		if ($user_uuid) {
			push @{$global_user_packages->{$package_type_id}}, $package;
		}
		else {
			push @{$global_curated_packages->{$package_type_id}}, $package;
		}
		$package_type_ids->{$package_type_id} += 1;
	}
	if ($verbose) {
		print "package count: ", scalar(@$packages), " package type count: ", scalar(keys %$package_type_ids), "\n";
	}
	if ($debug) {
		foreach my $package_type_id (sort {$a <=> $b} keys $package_type_ids) {
			my $package_type_name = $global_package_type_id_to_name->{$package_type_id};
			my $count = $package_type_ids->{$package_type_id};
			print "  package type id: $package_type_id package type name: $package_type_name count: $count\n";
		}
	}
}

# fetch all platform versions
sub fetch_platform_versions {
	my $curl = "curl -s --insecure -X GET -b cookies.txt $api_route_prefix/platforms/versions/all";
	my $result = `$curl`;
	my $platforms = from_json($result);
	foreach my $platform (@$platforms) {
		my $platform_name = $platform->{'full_name'};
		my $platform_version_uuid = $platform->{'platform_version_uuid'};
		$global_name_to_platform_version_uuid->{$platform_name} = $platform_version_uuid;
		$global_platform_version_uuid_to_name->{$platform_version_uuid} = $platform_name;
		my $platform_uuid = $platform->{'platform_uuid'};
		push @{$global_platforms->{$platform_uuid}}, $platform;
	}
	print "platform count: ", scalar(@$platforms), "\n" if ($verbose);
}

# fetch all tools
sub fetch_tools {
	my $curl = "curl -s --insecure -X GET -b cookies.txt $api_route_prefix/tools/public";
	my $result = `$curl`;
	$global_all_tools = from_json($result);
	my $count = 0;
	foreach my $tool (@$global_all_tools) {
		# skip commercial tools
		next if (! $commercial_tools && $tool->{'is_restricted'});
		$count += 1;
		my $tool_name = $tool->{'name'};
		my $tool_uuid = $tool->{'tool_uuid'};
		$global_name_to_tool_uuid->{$tool_name} = $tool_uuid;
		$global_tool_uuid_to_name->{$tool_uuid} = $tool_name;
		foreach my $package_type_name (@{$tool->{'package_type_names'}}) {
			next if (! defined($package_type_name));
			my $package_type_id = $global_name_to_package_type_id->{$package_type_name};
			if ($package_type_id) {
				push @{$global_tools_by_package_type_id->{$package_type_id}}, $tool;
				$global_package_type_id_to_tool_uuids->{$package_type_id}->{$tool_uuid} = 1;
				$global_tool_uuid_to_package_type_ids->{$tool_uuid}->{$package_type_id} = 1;
			}
		}
	}
	print "tool count: $count\n" if ($verbose);
}

#####################
#	Create Project	#
#####################

sub create_project_record { my ($user_uuid, $full_name, $short_name, $description, $affiliation) = @_ ;
	$user_uuid = uri_escape($user_uuid);
	$full_name = uri_escape($full_name);
	$short_name = uri_escape($short_name);
	$description = uri_escape($description);
	$affiliation = uri_escape($affiliation);
	my $trial_project_flag = uri_escape('');
	my $exclude_public_tools_flag = uri_escape('');
	my $curl = "curl -s --insecure -X POST -b cookies.txt \\
--data \"project_owner_uid=${user_uuid}\&full_name=${full_name}\&short_name=${short_name}\&description=${description}\&affiliation=${affiliation}\&trial_project_flag=${trial_project_flag}\&exclude_public_tools_flag=${exclude_public_tools_flag}\" $api_route_prefix/projects";
	my $result = '{}';
	if (! $noexecute) {
		$result = `$curl`;
	}
	my $project = from_json($result);
	print "create_project result: $result\n" if ($verbose);
	return $project;
}

sub _create_project { my ($user_uuid, $full_name, $short_name, $description) = @_ ;
	my $affiliation = 'Morgridge Institute for Research';
	my $project = create_project_record($user_uuid, $full_name, $short_name, $description, $affiliation);
	$global_current_project = $project;
	my $project_uuid = $project->{'project_uid'} || '';
	return $project_uuid;
}

sub create_project { my ($user_uuid) = @_ ;
	# project identification
	print 'Enter project full name: ';
	my $full_name = <STDIN>;
	chomp $full_name;
	return '' if (! $full_name);
	print 'Enter project short name: ';
	my $short_name = <STDIN>;
	chomp $short_name;
	return '' if (! $short_name);
	print 'Enter project description: ';
	my $description = <STDIN>;
	chomp $description;
	return '' if (! $description);
	my $project_uuid = _create_project($user_uuid, $full_name, $short_name, $description);
	return $project_uuid;
}

#################
#	Add Package	#
#################

sub add_package_record { my ($project_uuid, $package) = @_ ;
	$project_uuid = uri_escape($project_uuid);
	my $curl = "curl -s --insecure -X POST -b cookies.txt -F \"file=\@${package}\" $api_route_prefix/packages/versions/upload";
	my $result = '{}';
	if (! $noexecute) {
		$result = `$curl`;
	}
	my $package_record = from_json($result);
	print "add_package result: $result\n" if ($debug);
	return $package_record->{'package_uuid'} || '';
}

sub add_package { my ($project_uuid) = @_ ;
	my $package = $term->readline('Enter package bundle path: ');
	$package = trim($package);
	return '' if (! -r $package);
	my $package_uuid = add_package_record($project_uuid, $package);
	my $bogus = $package_uuid;
}

#########################
#	Create Assessment	#
#########################

sub create_assessment_record { my ($project_uuid, $package_uuid, $package_version_uuid, $tool_uuid, $tool_version_uuid, $platform_uuid, $platform_version_uuid) = @_ ;
	$project_uuid = uri_escape($project_uuid);
	$package_uuid = uri_escape($package_uuid);
	$package_version_uuid = uri_escape($package_version_uuid);
	$tool_uuid = uri_escape($tool_uuid);
	$tool_version_uuid = uri_escape($tool_version_uuid);
	$platform_uuid = uri_escape($platform_uuid);
	$platform_version_uuid = uri_escape($platform_version_uuid);
	my $curl = 'curl -s --insecure -X POST -b cookies.txt';
	$curl .= " --data \"project_uuid=${project_uuid}\&package_uuid=${package_uuid}";
	$curl .= "\&package_version_uuid=${package_version_uuid}" if ($package_version_uuid);
	$curl .= "\&tool_uuid=${tool_uuid}";
	$curl .= "\&tool_version_uuid=${tool_version_uuid}" if ($tool_version_uuid);
	$curl .= "\&platform_uuid=${platform_uuid}";
	$curl .= "\&platform_version_uuid=${platform_version_uuid}" if ($platform_version_uuid);
	my $ccurl = $curl . "\" $api_route_prefix/assessment_runs/check_compatibility";
	my $acurl = $curl . "\" $api_route_prefix/assessment_runs";
	my $result = '{}';
	my $compatible = 0;
	if (! $noexecute) {
		# check compatibility
		$result = `$ccurl`;
		if ($result eq 'Platform is compatible.') {
			# create assessment record
			$compatible = 1;
			$result = `$acurl`;
		}
	}
	print "create_assessment_record result: $result\n" if ($debug);
	return ($result, undef) if (! $compatible);
	my $assessment_record = from_json($result);
	if (exists($assessment_record->{'assessment_run_uuid'})) {
		return ('', $assessment_record->{'assessment_run_uuid'});
	}
	return ($result, undef);
}

sub select_project { my ($user_uuid, $default) = @_ ;
	my $project_uuid = undef;
	my $projects = fetch_projects($user_uuid);
	my $count = scalar(@$projects);
	my $index = $count;
	if ($count > 1) {
		$index = 1;
		my $i = 1;
		foreach my $project (@$projects) {
			print "$i) ", $project->{'full_name'}, ' [', $project->{'description'}, "]";
			print ' ', $project->{'project_uid'} if ($verbose);
			print "\n";
			$index = $i if ($project->{'full_name'} eq 'MyProject');
			$i += 1;
		}
		if (! $default) {
			print "Select project number [$index]: ";
			my $answer = <STDIN>;
			chomp $answer;
			print "answer: <$answer>\n" if ($debug);
			$index = $answer if ($answer && ($answer =~ m/^\d+$/) && ($answer >= 1 && $answer <= $count));
		}
	}
	if ($index >= 1) {
		$index -= 1;
		$project_uuid = $projects->[$index]->{'project_uid'};
	}
	$global_current_project = $projects->[$index];
	print "selected project uuid: $project_uuid\n";
	return $project_uuid;
}

sub show_projects { my ($user_uuid) = @_ ;
	my $total = 0;
	my $projects = fetch_projects($user_uuid);
	my $i = 1;
	foreach my $project (@$projects) {
		$total += 1;
		print "$i) ", $project->{'full_name'}, ' [', $project->{'description'}, "]";
		print ' ', $project->{'project_uid'} if ($verbose);
		print "\n";
		$i += 1;
	}
	print "Total: $total\n";
}

sub show_all_platforms {
	my $pcount = 0;
	foreach my $platform_uuid (sort {$global_platforms->{$a}->[0]->{'full_name'} cmp $global_platforms->{$b}->[0]->{'full_name'}} keys %$global_platforms) {
		my $platform_versions = $global_platforms->{$platform_uuid};
		(my $platform_name = $platform_versions->[0]->{'full_name'}) =~ s/ $platform_versions->[0]->{'version_string'}//;
		print $platform_name, ' [', scalar(@$platform_versions), ']';
		print ' ', $platform_uuid if ($verbose);
		print "\n";
		foreach my $platform_version (sort {$a->{'full_name'} cmp $b->{'full_name'}} @$platform_versions) {
			$pcount += 1;
			print '  ', $platform_version->{'platform_path'};
			print ' ', $platform_version->{'platform_version_uuid'} if ($verbose);
			print "\n";
		}
		print "\n";
	}
	print "Platforms: $pcount\n";
}

sub show_each_package_by_type { my ($packages) = @_ ;
	my $ptcount = 0;
	my $pcount = 0;
	foreach my $package_type_id (sort {$a <=> $b} keys $packages) {
		$ptcount += 1;
		print $package_type_id, ') ', $global_package_type_id_to_name->{$package_type_id}, ' [', scalar(@{$packages->{$package_type_id}}), "]\n";
		foreach my $package (@{$packages->{$package_type_id}}) {
			$pcount += 1;
			print "\t", $package->{'name'}, "\n";
		}
		print "\n";
	}
	print "Package Types: $ptcount Packages: $pcount\n";
}

sub show_all_tools { my ($bypackage) = @_ ;
	if ($bypackage) {
		my $total = 0;
		foreach my $package_type_id (sort {$a <=> $b} keys $global_tools_by_package_type_id) {
			print $package_type_id, ') ', $global_package_type_id_to_name->{$package_type_id}, ' [', scalar(@{$global_tools_by_package_type_id->{$package_type_id}}), "]\n";
			foreach my $tool (@{$global_tools_by_package_type_id->{$package_type_id}}) {
				$total += 1;
				print "\t", $tool->{'name'}, ' [', scalar(@{$tool->{'platform_names'}}), "]\n";
			}
			print "\n";
		}
		print "Total: $total\n";
	}
	else {
		my $tcount = 0;
		foreach my $tool (@$global_all_tools) {
			next if (! $commercial_tools && $tool->{'is_restricted'});
			$tcount += 1;
			print $tool->{'name'}, ' [', scalar(@{$tool->{'version_strings'}}), "]\n";
		}
		print "\n";
		print "Tools: $tcount\n";
	}
}

sub show_all_package_types_for_tool {
	# sort the tools by the first package_type_id in the list
	my $total = 0;
	foreach my $tool (sort {$global_name_to_package_type_id->{$a->{'package_type_names'}->[0]} <=> $global_name_to_package_type_id->{$b->{'package_type_names'}->[0]}} @$global_all_tools) {
		next if (! $commercial_tools && $tool->{'is_restricted'});
		$total += 1;
		print $tool->{'name'}, ': ', join(', ', @{$tool->{'package_type_names'}}), "\n";
	}
	print "Total: $total\n";
}

sub show_current_project {
	print "\n", 'Current project: ', $global_current_project->{'full_name'}, "\n";
}

sub show_current_packages { my ($packages, $package_type_id_filter) = @_ ;
	my $answer = "Current packages [$global_package_set] (%d): ";
	my $total = 0;
	foreach my $package_type_id (sort {$a <=> $b} keys $packages) {
		next if (! exists($package_type_id_filter->{$package_type_id}));
		my $package_type = $global_package_type_id_to_name->{$package_type_id};
		my $count = scalar(@{$packages->{$package_type_id}});
		$answer .=  "$package_type [$count] ";
		$total += $count;
	}
	printf "$answer\n\n", $total;
}

sub show_package_type_id_filter { my ($filter) = @_ ;
	print 'package type id filter [', scalar(keys %$filter), "]:\n  ", join(",  ", sort {"\L$a" cmp "\L$b"} map {$global_package_type_id_to_name->{$_}} sort {$a <=> $b} keys %$filter), "\n\n";
}

sub show_tool_uuid_filter { my ($filter) = @_ ;
	print 'tool filter [', scalar(keys %$filter), "]:\n"; 
	print '  ', join(",  ", map {$global_tool_uuid_to_name->{$_}} sort {lc($global_tool_uuid_to_name->{$a}) cmp lc($global_tool_uuid_to_name->{$b})} keys %$filter), "\n\n";
}

sub show_platform_version_uuid_filter { my ($filter) = @_ ;
	print 'platform version filter [', scalar(keys %$filter), "]:\n  ", join("\n  ", sort {"\L$a" cmp "\L$b"} map {$global_platform_version_uuid_to_name->{$_}} keys %$filter), "\n\n";
}

sub _select_package_type_id_filter { my ($all, $packages, $package_type_id_list) = @_ ;
	my $filter = {};
	if (! $all) {
		foreach my $package_type_id (@$package_type_id_list) {
			# restrict filter by existence of package of package_type_id
			if (exists($packages->{$package_type_id})) {
				$filter->{$package_type_id} = 1;
			}
		}
	}
	if ($all || ! %$filter) {
		foreach my $package_type_id (sort {$a <=> $b} keys $packages) {
			$filter->{$package_type_id} = 1;
		}
	}
	return $filter;
}

sub _package_type_names_to_package_type_ids { my ($package_type_names) = @_ ;
	my $package_type_id_list = [];
	foreach my $package_type_name (@$package_type_names) {
		my $package_type_id = $global_name_to_package_type_id->{$package_type_name};
		push @$package_type_id_list, $package_type_id if ($package_type_id);
	}
	return $package_type_id_list;
}

sub select_package_type_id_filter { my ($all, $packages) = @_ ;
	my @package_type_id_list = ();
	if (! $all) {
		foreach my $package_type_id (sort {$a <=> $b} keys $packages) {
			print $package_type_id, ') ', $global_package_type_id_to_name->{$package_type_id}, "\n";
			push @package_type_id_list, $package_type_id;
		}
		print 'Enter [[-]<d>[,] ... <d>|A]: ';
		my $answer = <STDIN>;
		chomp $answer;
		print "answer: <$answer>\n" if ($debug);
		# select all package types
		if (! $answer || ($answer =~ m/^a$/i)) {
			$all = 1;
		}
		# select package types from list
		else {
			$answer =~ s/,/ /g;
			if ($answer =~ m/\-/) {
				$answer =~ s/\-//g;
				my %list;
				$list{$_} = 1 foreach split ' ', $answer;
				@package_type_id_list = grep(! defined($list{$_}), @package_type_id_list);
			}
			else {
				@package_type_id_list = split ' ', $answer;
			}
		}
	}
	my $filter = _select_package_type_id_filter($all, $packages, \@package_type_id_list);
	return $filter;
}

sub refine_package_type_id_filter { my ($package_type_id_filter, $tool_uuid_filter) = @_ ;
	# start with empty new package_type_id_filter
	my $filter = {};
	# iterate over tool_uuid in tool_uuid_filter
	foreach my $tool_uuid (keys %$tool_uuid_filter) {
		# iterate over package_type_id for tool_uuid
		foreach my $package_type_id (keys %{$global_tool_uuid_to_package_type_ids->{$tool_uuid}}) {
			# if package_type_id_filter has package_type_id preserve it in new package_type_id_filter
			if (exists($package_type_id_filter->{$package_type_id})) {
				$filter->{$package_type_id} = 1;
			}
		}
	}
	# return new package_type_id_filter
	return $filter;
}

# 
sub _select_tool_uuid_filter { my ($all, $tool_uuid_list) = @_ ;
	my $filter = {};
	if (! $all) {
		foreach my $tool_uuid (@$tool_uuid_list) {
			$filter->{$tool_uuid} = 1;
		}
	}
	if ($all || ! %$filter) {
		foreach my $package_type_id (sort {$a <=> $b} keys $global_tools_by_package_type_id) {
			foreach my $tool (@{$global_tools_by_package_type_id->{$package_type_id}}) {
				$filter->{$tool->{'tool_uuid'}} = 1;
			}
		}
	}
	return $filter;
}

sub _tool_names_to_tool_uuid_list { my ($tool_names) = @_ ;
	my $tool_uuid_list = [];
	foreach my $tool_name (@$tool_names) {
		my $tool_uuid = $global_name_to_tool_uuid->{$tool_name};
		push @$tool_uuid_list, $tool_uuid if ($tool_uuid);
	}
	return $tool_uuid_list;
}

sub select_tool_uuid_filter { my ($all, $package_type_id_filter) = @_ ;
	my @tool_uuid_list = ();
	if (! $all) {
		my $index = 1;
		my $tool_uuids = [];
		foreach my $tool (sort {$a->{'name'} cmp $b->{'name'}} @$global_all_tools) {
			next if (! $commercial_tools && $tool->{'is_restricted'});
			print $index, ') ', $tool->{'name'}, "\n";
			$tool_uuids->[$index] = $tool->{'tool_uuid'};
			$index += 1;
		}
		print 'Enter [[-]<d>[,] .. <d>|A]: ';
		my $answer = <STDIN>;
		chomp $answer;
		print "answer: <$answer>\n" if ($debug);
		# select all tools for all package types
		if ($answer =~ m/^a$/i) {
			$all = 1;
		}
		else {
			my @indexes = (1 .. $index-1);
			$answer =~ s/,/ /g;
			if ($answer =~ m/\-/) {
				$answer =~ s/\-//g;
				my %list;
				$list{$_} = 1 foreach split ' ', $answer;
				@indexes = grep(! defined($list{$_}), @indexes);
			}
			else {
				@indexes = split ' ', $answer;
			}
			foreach my $index (@indexes) {
				push @tool_uuid_list, $tool_uuids->[$index];
			}
		}
	}
	my $filter = _select_tool_uuid_filter($all, \@tool_uuid_list);
	return $filter;
}

sub refine_tool_uuid_filter { my ($tool_uuid_filter, $package_type_id_filter) = @_ ;
	# start with empty new tool_uuid_filter
	my $filter = {};
	# iterate over package_type_id in package_type_id_filter
	foreach my $package_type_id (keys %$package_type_id_filter) {
		# iterate over tool_uuid for package_type_id
		foreach my $tool_uuid (keys %{$global_package_type_id_to_tool_uuids->{$package_type_id}}) {
			# if tool_uuid_filter has tool_uuid preserve it in new tool_uuid_filter
			if (exists($tool_uuid_filter->{$tool_uuid})) {
				$filter->{$tool_uuid} = 1;
			}
		}
	}
	# return new tool_uuid_filter
	return $filter;
}

sub _select_platform_version_uuid_filter { my ($all, $platform_version_uuid_list) = @_ ;
	my $filter = {};
	if (! $all) {
		foreach my $platform_version_uuid (@$platform_version_uuid_list) {
			$filter->{$platform_version_uuid} = 1;
		}
	}
	if ($all || ! %$filter) {
		foreach my $platform_versions (values %$global_platforms) {
			foreach my $platform_version (@$platform_versions) {
				$filter->{$platform_version->{'platform_version_uuid'}} = 1;
			}
		}
	}
	return $filter;
}

sub _platform_version_names_to_platform_version_uuid_list { my ($platform_version_names) = @_ ;
	my $platform_version_uuid_list = [];
	foreach my $platform_version_name (@$platform_version_names) {
		my $platform_version_uuid = $global_name_to_platform_version_uuid->{$platform_version_name};
		push @$platform_version_uuid_list, $platform_version_uuid if ($platform_version_uuid);
	}
	return $platform_version_uuid_list;
}

sub select_platform_version_uuid_filter { my ($all) = @_ ;
	my @platform_version_uuid_list = ();
	if (! $all) {
		my $index = 1;
		my $platform_version_uuids = [];
        foreach my $platform_uuid (sort {$global_platforms->{$a}->[0]->{'full_name'} cmp $global_platforms->{$b}->[0]->{'full_name'}} keys %$global_platforms) {
			my $platform_versions = $global_platforms->{$platform_uuid};
			foreach my $platform_version (sort {$a->{'full_name'} cmp $b->{'full_name'}} @$platform_versions) {
				print $index, ') ', $platform_version->{'full_name'}, "\n";
				$platform_version_uuids->[$index] = $platform_version->{'platform_version_uuid'};
				$index += 1;
			}
		}
		print 'Enter [[-]<d>[,] .. <d>|A]: ';
		my $answer = <STDIN>;
		chomp $answer;
		print "answer: <$answer>\n" if ($debug);
		# select all platform versions
		if (! $answer || ($answer =~ m/^a$/i)) {
			$all = 1;
		}
		# select platform versions from list
		else {
			my @indexes = (1 .. $index-1);
			$answer =~ s/,/ /g;
			if ($answer =~ m/\-/) {
				$answer =~ s/\-//g;
				my %list;
				$list{$_} = 1 foreach split ' ', $answer;
				@indexes = grep(! defined($list{$_}), @indexes);
			}
			else {
				@indexes = split ' ', $answer;
			}
			foreach my $index (@indexes) {
				push @platform_version_uuid_list, $platform_version_uuids->[$index];
			}
		}
	}
	my $filter = _select_platform_version_uuid_filter($all, \@platform_version_uuid_list);
	return $filter;
}

sub all_cross_product { my ($project_uuid, $package_type_id_filter, $tool_uuid_filter, $platform_version_uuid_filter, $packages) = @_ ;
	my $list_platforms = 0;
	if ($project_uuid eq 'v') {
		$list_platforms = 1;
		$project_uuid = '';
	}
	my $count = 0;
	my $scount = 0;
	my $fcount = 0;
	my $pcount = 0;
	foreach my $package_type_id (sort {$a <=> $b} keys $packages) {
		next if (! exists($package_type_id_filter->{$package_type_id}));
		my $local_packagecount = 0;
		foreach my $package (@{$packages->{$package_type_id}}) {
			my $package_name = $package->{'name'};
			my $package_uuid = $package->{'package_uuid'};
			my $package_version_uuid = ''; # always use latest package version
			print "package: $package_name";
			print " $package_uuid (", $global_package_type_id_to_name->{$package_type_id}, ')' if ($debug);
			print "\n";
			$pcount += 1;
			my $tools_for_package = $global_tools_by_package_type_id->{$package_type_id};
			foreach my $tool (@$tools_for_package) {
				my $tool_name = $tool->{'name'};
				my $tool_uuid = $tool->{'tool_uuid'};
				my $tool_version_uuid = ''; # always use latest tool version
				next if (! exists($tool_uuid_filter->{$tool_uuid}));
				print "  tool: $tool_name";
				print " $tool_uuid" if ($debug);
				print "\n" if ($list_platforms);
				my $platform_count = 0;
        		foreach my $platform_uuid (sort {$global_platforms->{$a}->[0]->{'full_name'} cmp $global_platforms->{$b}->[0]->{'full_name'}} keys %$global_platforms) {
					my $platform_versions = $global_platforms->{$platform_uuid};
                	foreach my $platform_version (sort {$a->{'full_name'} cmp $b->{'full_name'}} @$platform_versions) {
						my $platform_name = $platform_version->{'full_name'};
						my $platform_version_uuid = $platform_version->{'platform_version_uuid'};
						next if (! exists($platform_version_uuid_filter->{$platform_version_uuid}));
						if ($list_platforms) {
							print "    platform: $platform_name";
							print " $platform_uuid ($platform_version_uuid)" if ($debug);
						}
						if ($project_uuid) {
							my ($status, $assessment_record_uuid) = 
								create_assessment_record($project_uuid, $package_uuid, $package_version_uuid, 
								$tool_uuid, $tool_version_uuid, $platform_uuid, $platform_version_uuid);
							if (! $status) {
								$scount += 1;
								print ' ', $assessment_record_uuid;
							}
							else {
								$fcount += 1;
								print ' ', $status;
							}
						}
						print "\n" if ($list_platforms);
						$platform_count += 1;
						$count += 1;
					}
				}
				print " platform count: [$platform_count]\n" if (! $list_platforms);
			}
			print "\n";
			# exit loop if global_packagecount number of packages have been processed
			$local_packagecount += 1;
			last if ($global_packagecount && ($local_packagecount >= $global_packagecount));
		}
	}
	print "Assessment count: $count Package count: $pcount Success count: $scount Failed count: $fcount\n";
}

#####################
#	Global Commands	#
#####################

my $commands = [
	['debug',					'toggle debug'],
	['verbose',					'toggle verbose'],
	['selectcuratedpackages',	'select curated packages for cross product use'],
	['selectuserpackages',		'select user packages for cross product use'],
	['addpackage',				'add a package by file name NYI'],

	['listpackagesbytype',		'list packages by package type'],
	['listplatforms',			'list platforms with versions'],
	['listalltools',			'list all tools by name'],
	['listtoolsbypackagetype',	'list tools for each package type'],
	['listpackagetypetools',	'list package types for each tool'],

	['ptfilter',				'set the package type filter'],
	['tfilter',					'set the tool filter'],
	['pvfilter',				'set the platform version filter'],

	['listprojects',			'list all projects for user'],
	['createproject',			'create a new project'],
	['selectproject',			'select project from a list'],

	['listcrossproduct',		'list cross product entries with platform version count'],
	['vlistcrossproduct',		'list cross product entries with platform version names'],
	['createcrossproduct',		'create cross product package x tool x platform version assessment records'],

	['projectspecs',			'select project specs from a list'],
];
my $max_command_length = 0;
foreach my $command (@$commands) {
	my $length = length($command->[0]);
	$max_command_length = $length if ($length > $max_command_length);
}

my $projectspecs = {
	'cpaatcp'	=> {
		'full_name'					=> 'C Packages All Applicable Tools CentOS Platforms',
		'description'				=> 'All C/C++ packages, all applicable tools, centos platforms',
		'package_type_names'		=>['C/C++'],
		'platform_version_names'	=> [
			'CentOS Linux 5 32-bit 5.11 32-bit',
			'CentOS Linux 5 64-bit 5.11 64-bit',
			'CentOS Linux 6 32-bit 6.7 32-bit',
			'CentOS Linux 6 64-bit 6.7 64-bit',
		],
	},
	'cpaatdp'	=> {
		'full_name'					=> 'C Packages All Applicable Tools Debian Platforms',
		'description'				=> 'All C/C++ packages, all applicable tools, debian platforms',
		'package_type_names'		=>['C/C++'],
		'platform_version_names'	=> [
			'Debian Linux 7.11 64-bit',
			'Debian Linux 8.5 64-bit',
		],
	},
	'cpaatfp'	=> {
		'full_name'					=> 'C Packages All Applicable Tools Fedora Platforms',
		'description'				=> 'All C/C++ packages, all applicable tools, fedora platforms',
		'package_type_names'		=>['C/C++'],
		'platform_version_names'	=> [
			'Fedora Linux 18 64-bit',
			'Fedora Linux 19 64-bit',
			'Fedora Linux 20 64-bit',
			'Fedora Linux 21 64-bit',
			'Fedora Linux 22 64-bit',
			'Fedora Linux 23 64-bit',
			'Fedora Linux 24 64-bit',
		],
	},
	'cpaatrhp'	=> {
		'full_name'					=> 'C Packages All Applicable Tools RedHat Platforms',
		'description'				=> 'All C/C++ packages, all applicable tools, redhat platforms',
		'package_type_names'		=>['C/C++'],
		'platform_version_names'	=> [
			'Red Hat Enterprise Linux 6 32-bit 6.7 32-bit',
			'Red Hat Enterprise Linux 6 64-bit 6.7 64-bit',
		],
	},
	'cpaatslp'	=> {
		'full_name'					=> 'C Packages All Applicable Tools Scientific Linux Platforms',
		'description'				=> 'All C/C++ packages, all applicable tools, scientific linux platforms',
		'package_type_names'		=>['C/C++'],
		'platform_version_names'	=> [
			'Scientific Linux 5 32-bit 5.11 32-bit',
			'Scientific Linux 5 32-bit 5.9 32-bit',
			'Scientific Linux 5 64-bit 5.11 64-bit',
			'Scientific Linux 6 32-bit 6.7 32-bit',
			'Scientific Linux 6 64-bit 6.7 64-bit',
		],
	},
	'cpaatup'	=> {
		'full_name'					=> 'C Packages All Applicable Tools Ubuntu Platforms',
		'description'				=> 'All C/C++ packages, all applicable tools, ubuntu platforms',
		'package_type_names'		=>['C/C++'],
		'platform_version_names'	=> [
			'Ubuntu Linux 10.04 LTS 64-bit Lucid Lynx',
			'Ubuntu Linux 12.04 LTS 64-bit Precise Pangolin',
			'Ubuntu Linux 14.04 LTS 64-bit Trusty Tahr',
			'Ubuntu Linux 16.04 LTS 64-bit Xenial Xerus',
		],
	},
	'jpaatu16'	=> {
		'full_name'					=> 'Java Packages All Applicable Tools Ubuntu 16 Platform',
		'description'				=> 'All java 7 packages, all applicable tools, ubuntu 16 platform',
		'package_type_names'		=>['Java 7 Source Code', 'Java 7 Bytecode'],
		'platform_version_names'	=> ['Ubuntu Linux 16.04 LTS 64-bit Xenial Xerus'],
	},
	'ppaatu16'	=> {
		'full_name'					=> 'Python Packages All Applicable Tools Ubuntu 16 Platform',
		'description'				=> 'All python 2 and python 3 packages, all applicable tools, ubuntu 16 platform',
		'package_type_names'		=>['Python2', 'Python3'],
		'platform_version_names'	=> ['Ubuntu Linux 16.04 LTS 64-bit Xenial Xerus'],
	},
	'apaatau12'	=> {
		'full_name'					=> 'Android Packages All Applicable Tools Android Ubuntu 12 Platform',
		'description'				=> 'Android java and .apk packages, all applicable tools, ubuntu 12 platform',
		'package_type_names'		=>['Android Java Source Code', 'Android .apk'],
		'platform_version_names'	=> ['Android Android on Ubuntu 12.04 64-bit'],
	},
	'rpaatu16'	=> {
		'full_name'					=> 'Ruby Packages All Applicable Tools Ubuntu 16 Platform',
		'description'				=> 'All ruby, ruby sinatra, and ruby on rails packages, all applicable tools, ubuntu 16 platform',
		'package_type_names'		=> ['Ruby', 'Ruby Sinatra', 'Ruby on Rails'],
		'platform_version_names'	=> ['Ubuntu Linux 16.04 LTS 64-bit Xenial Xerus'],
	},
	'wsltu16'	=> {
		'full_name'					=> 'Web Scripting Packages *Lint Tools Ubuntu 16 Platform',
		'description'				=> 'All web scripting packages, css lint, eslint xml lint tools, ubuntu 16 platform',
		'package_type_names'		=> ['Web Scripting'],
		'tool_names'				=> ['CSS Lint', 'ESLint', 'XML Lint'],
		'platform_version_names'	=> ['Ubuntu Linux 16.04 LTS 64-bit Xenial Xerus'],
	},
	'wsphptu16'	=> {
		'full_name'					=> 'Web Scripting Packages PHP Tools Ubuntu 16 Platform',
		'description'				=> 'All web scripting packages, php tools, ubuntu 16 platform',
		'package_type_names'		=> ['Web Scripting'],
		'tool_names'				=> ['PHPMD', 'PHP_CodeSniffer'],
		'platform_version_names'	=> ['Ubuntu Linux 16.04 LTS 64-bit Xenial Xerus'],
	},
	'wsmtu16'	=> {
		'full_name'					=> 'Web Scripting Packages Misc Tools Ubuntu 16 Platform',
		'description'				=> 'All web scripting packages, php tools, ubuntu 16 platform',
		'package_type_names'		=> ['Web Scripting'],
		'tool_names'				=> ['Flow', 'HTML Tidy', 'JSHint', 'Retire.js'],
		'platform_version_names'	=> ['Ubuntu Linux 16.04 LTS 64-bit Xenial Xerus'],
	},
};

sub menu_driver { my ($user_uuid) = @_ ;
	# default project to MyProject
	my $project_uuid = select_project($user_uuid, 1);
	# default to curated packages with associated package and tool filters
	my $packages = $global_curated_packages;
	if (! %$packages) {
		$packages = $global_user_packages;
		$global_package_set = 'user';
	}
	my $package_type_id_filter = select_package_type_id_filter(1, $packages);
	my $tool_uuid_filter = select_tool_uuid_filter(1, $package_type_id_filter);
	my $platform_version_uuid_filter = select_platform_version_uuid_filter(1);
	my $show_filters = 1;
	while (1) {
		show_current_project();
		show_current_packages($packages, $package_type_id_filter);
		if ($show_filters) {
			show_package_type_id_filter($package_type_id_filter);
			show_tool_uuid_filter($tool_uuid_filter);
			show_platform_version_uuid_filter($platform_version_uuid_filter);
		}
		$show_filters = 1;
		my $index = 1;
		foreach my $parts (@$commands) {
			my $command = $parts->[0];
			my $documentation = $parts->[1];
			printf("%2d) %-${max_command_length}s    %s\n", $index, $command, $documentation);
			$index += 1;
		}

		print 'Debug Mode ' if ($debug);
		print 'Command: ';
		my $answer = <STDIN>;
		chomp $answer;
		$answer = trim($answer);
		if ($answer =~ m/^\d+$/) {
			$answer -= 1;
			$answer = $commands->[$answer]->[0];
		}
		print "answer: <$answer>\n" if ($debug);
		print "\n";
		next if (! $answer);
		last if ($answer =~ m/^q$/i);
		if ('debug' =~ m/^$answer/i) {
			$debug = ! $debug;
		}
		elsif ('verbose' =~ m/^$answer/i) {
			$verbose = ! $verbose;
		}
		elsif ('selectcuratedpackages' =~ m/^$answer/i) {
			if ($global_package_set ne 'curated') {
				$packages = $global_curated_packages;
				$global_package_set = 'curated';
				$package_type_id_filter = select_package_type_id_filter(1, $packages);
				$tool_uuid_filter = select_tool_uuid_filter(1, $package_type_id_filter);
			}
		}
		elsif ('selectuserpackages' =~ m/^$answer/i) {
			if ($global_package_set ne 'user') {
				$packages = $global_user_packages;
				$global_package_set = 'user';
				$package_type_id_filter = select_package_type_id_filter(1, $packages);
				$tool_uuid_filter = select_tool_uuid_filter(1, $package_type_id_filter);
			}
		}
		elsif ('listpackagesbytype' =~ m/^$answer/i) {
			show_each_package_by_type($packages);
			$show_filters = 0;
		}
		elsif ('listplatforms' =~ m/^$answer/i) {
			show_all_platforms();
			$show_filters = 0;
		}
		elsif ('listalltools' =~ m/^$answer/i) {
			show_all_tools(0);
			$show_filters = 0;
		}
		elsif ('listtoolsbypackagetype' =~ m/^$answer/i) {
			show_all_tools(1);
			$show_filters = 0;
		}
		elsif ('listpackagetypetools' =~ m/^$answer/i) {
			show_all_package_types_for_tool();
			$show_filters = 0;
		}
		elsif ('ptfilter' =~ m/^$answer/i) {
			$package_type_id_filter = select_package_type_id_filter(0, $packages);
			$tool_uuid_filter = refine_tool_uuid_filter($tool_uuid_filter, $package_type_id_filter);
			# if tool filter is reduced to null - recompute it from full refined by package filter
			if (! %$tool_uuid_filter) {
				$tool_uuid_filter = refine_tool_uuid_filter(select_tool_uuid_filter(1, $package_type_id_filter), $package_type_id_filter);
			}
		}
		elsif ('tfilter' =~ m/^$answer/i) {
			$tool_uuid_filter = select_tool_uuid_filter(0, $package_type_id_filter);
			$package_type_id_filter = refine_package_type_id_filter($package_type_id_filter, $tool_uuid_filter);
			# if package filter is reduced to null - recompute it from full refined by tool filter
			if (! %$package_type_id_filter) {
				$package_type_id_filter = refine_package_type_id_filter(select_package_type_id_filter(1, $packages), $tool_uuid_filter);
			}
		}
		elsif ('pvfilter' =~ m/^$answer/i) {
			$platform_version_uuid_filter = select_platform_version_uuid_filter(0);
		}
		elsif ('listprojects' =~ m/^$answer/i) {
			$project_uuid = show_projects($user_uuid);
			$show_filters = 0;
		}
		elsif ('createproject' =~ m/^$answer/i) {
			$project_uuid = create_project($user_uuid);
		}
		elsif ('selectproject' =~ m/^$answer/i) {
			$project_uuid = select_project($user_uuid, 0);
		}
		elsif ('listcrossproduct' =~ m/^$answer/i) {
			all_cross_product('', $package_type_id_filter, $tool_uuid_filter, $platform_version_uuid_filter, $packages);
			$show_filters = 0;
		}
		elsif ('vlistcrossproduct' =~ m/^$answer/i) {
			all_cross_product('v', $package_type_id_filter, $tool_uuid_filter, $platform_version_uuid_filter, $packages);
			$show_filters = 0;
		}
		elsif ('createcrossproduct' =~ m/^$answer/i) {
			all_cross_product($project_uuid, $package_type_id_filter, $tool_uuid_filter, $platform_version_uuid_filter, $packages);
			$show_filters = 0;
		}
		elsif ('projectspecs' =~ m/^$answer/i) {
			my $subindex = 1;
			foreach my $short_name (sort keys %$projectspecs) {
				printf("%2d) %-10s    %s\n", $subindex, $short_name, $projectspecs->{$short_name}->{'full_name'});
				$subindex += 1;
			}
			print 'Debug Mode ' if ($debug);
			print 'Project: ';
			my $short_name = <STDIN>;
			chomp $short_name;
			$short_name = trim($short_name);
			if ($short_name =~ m/^\d+$/) {
				$short_name -= 1;
				$short_name = (sort keys %$projectspecs)[$short_name];
			}
			if ($short_name) {
				my $package_type_id_list = _package_type_names_to_package_type_ids($projectspecs->{$short_name}->{'package_type_names'});
				$package_type_id_filter = _select_package_type_id_filter(0, $packages, $package_type_id_list);
				if (defined($projectspecs->{$short_name}->{'tool_names'})) {
					my $tool_uuid_list = _tool_names_to_tool_uuid_list($projectspecs->{$short_name}->{'tool_names'});
					$tool_uuid_filter = _select_tool_uuid_filter(0, $tool_uuid_list);
					$tool_uuid_filter = refine_tool_uuid_filter($tool_uuid_filter, $package_type_id_filter);
				}
				else {
					$tool_uuid_filter = refine_tool_uuid_filter(select_tool_uuid_filter(1, $package_type_id_filter), $package_type_id_filter);
				}
				my $platform_version_uuid_list = _platform_version_names_to_platform_version_uuid_list($projectspecs->{$short_name}->{'platform_version_names'});
				$platform_version_uuid_filter = _select_platform_version_uuid_filter(0, $platform_version_uuid_list);
				all_cross_product('', $package_type_id_filter, $tool_uuid_filter, $platform_version_uuid_filter, $packages);
			}
			$show_filters = 0;
		}
		elsif ('addpackage' =~ m/^$answer/i) {
			add_package($project_uuid);
		}
	}
}

sub usage {
	print "usage: $0 [-help -debug -verbose -quiet -noexecute -packagecount <integer> -commercial -server <string> -username <string> -password <string>]\n";
	exit;
}

my $help = 0;
my $result = GetOptions(
	'help'				=> \$help,
	'debug'				=> \$debug,
	'verbose'			=> \$verbose,
	'quiet'				=> \$quiet,
	'commercial'		=> \$commercial_tools,
	'packagecount=i'	=> \$global_packagecount,
	'noexecute'			=> \$noexecute,
	'server=s'			=> \$swampserver,
	'username=s'		=> \$username,
	'password=s'		=> \$password,
);
usage() if ($help || ! $result);

if (! $swampserver) {
	$swampserver = `hostname`;
	chomp $swampserver;
	print "Enter server [$swampserver]: ";
	my $answer = <STDIN>;
	chomp $answer;
	if ($answer) {
		$swampserver = $answer;
	}
}
($api_route_prefix, $swampserver) = set_api_route_prefix($swampserver);
if (! $api_route_prefix) {
	print "Error - could not set route_prefix for: $swampserver\n";
	exit(0);
}
print "api_route_prefix for $swampserver: $api_route_prefix\n" if ($debug);
if (! $username) {
	$username = `whoami`;
	chomp $username;
	print "Enter username [$username]: ";
	my $answer = <STDIN>;
	chomp $answer;
	if ($answer) {
		$username = $answer;
	}
}
if (! $password) {
	$password = prompt('Enter password: ', -e => '*');
}
my ($error, $user_uuid) = login($username, $password);
if ($error) {
	print "Error - could not log in to server: $swampserver with username: $username result: $error\n";
	exit(0);
}
if ($user_uuid) {
	fetch_package_types();
	fetch_packages();
	fetch_packages($user_uuid);
	fetch_platform_versions();
	fetch_tools();
	menu_driver($user_uuid);
}
