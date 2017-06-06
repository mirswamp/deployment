#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use JSON;
use URI::Escape;
use Term::ReadLine;
use IO::Prompt;

my $debug		= 0;
my $verbose		= 0;
my $noexecute	= 0;
my $quiet		= 0;

# Terminal
my $term = new Term::ReadLine($0);

# SWAMP server
my $swampserver;

# login credentials
my $username;
my $password;

# route prefix
my $route_prefix;

# current project
my $global_current_project = {};

# hash of package lists keyed on package_type_id
my $global_curated_packages = {};
my $global_user_packages = {};
my $global_package_type_to_id = {};
my $global_package_id_to_type = {};

# hash of platform version lists keyed on platform_uuid
my $global_platforms = {};
my $global_platform_version_uuid_to_name = {};

# hash of tool version lists keyed on package_type_id
my $global_tools_by_package = {};
my $global_all_tools = {};
my $global_tool_uuid_to_name = {};

sub trim { my ($string) = @_ ;
	$string =~ s/^\s+|\s+$//g;
	return $string;
}

# determine route prefix
sub set_route_prefix { my ($server) = @_ ;
	my $route_prefix = "https://$server/swamp-web-server/public";
	my $curl = "curl -s --insecure -X GET $route_prefix/environment";
	my $result = `$curl`;
	print "$route_prefix result: $result\n" if ($debug);
	if (! $result || ($result =~ m/\<html/)) {
		$route_prefix = "https://$server";
		$curl = "curl -s --insecure -X GET $route_prefix/environment";
		$result = `$curl`;
		print "$route_prefix result: $result\n" if ($debug);
	}
	return undef if (! $result || ($result =~ m/\<html/));
	return $route_prefix;
}

# login
sub login { my ($username, $password) = @_ ;
	$password = uri_escape($password);
	my $curl = "curl -s --insecure -X POST -c cookies.txt --data \"username=${username}\&password=${password}\" $route_prefix/login";
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
	my $curl = "curl -s --insecure -X GET -b cookies.txt $route_prefix/users/$user_uuid/projects";
	my $result = `$curl`;
	my $projects = from_json($result);
	print "project count: ", scalar(@$projects), "\n" if ($verbose);
	return $projects;
}

# fetch package types
sub fetch_package_types {
	my $curl = "curl -s --insecure -X GET -b cookies.txt $route_prefix/packages/types";
	my $result = `$curl`;
	my $package_types = from_json($result);
	foreach my $package_type (@$package_types) {
		my $package_type_name = $package_type->{'name'};
		my $package_type_id = $package_type->{'package_type_id'};
		$global_package_type_to_id->{$package_type_name} = $package_type_id;
		$global_package_id_to_type->{$package_type_id} = $package_type_name;
		print $package_type_id, ') ', $package_type_name, "\n" if ($debug);
	}
}

# fetch packages - public curated or user packages
sub fetch_packages { my ($user_uuid) = @_ ;
	my $curl = "curl -s --insecure -X GET -b cookies.txt $route_prefix/packages/public";
	if ($user_uuid) {
		$curl = "curl -s --insecure -X GET -b cookies.txt $route_prefix/packages/users/$user_uuid";
	}
	my $result = `$curl`;
	my $packages = from_json($result);
	my $package_type_ids = {};
	foreach my $package (@$packages) {
		my $package_type_id = $package->{'package_type_id'};
		# exclude packages whose package_type is not enabled
		next if (! exists($global_package_id_to_type->{$package_type_id}));
		my $package_type = $package->{'package_type'};
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
			my $package_type = $global_package_id_to_type->{$package_type_id};
			my $count = $package_type_ids->{$package_type_id};
			print "  package type id: $package_type_id package type: $package_type count: $count\n";
		}
	}
}

# fetch all platform versions
sub fetch_platform_versions {
	my $curl = "curl -s --insecure -X GET -b cookies.txt $route_prefix/platforms/versions/all";
	my $result = `$curl`;
	my $platforms = from_json($result);
	foreach my $platform (@$platforms) {
		$global_platform_version_uuid_to_name->{$platform->{'platform_version_uuid'}} = $platform->{'full_name'};
		my $platform_uuid = $platform->{'platform_uuid'};
		push @{$global_platforms->{$platform_uuid}}, $platform;
	}
	print "platform count: ", scalar(@$platforms), "\n" if ($verbose);
}

# fetch all tools
sub fetch_tools {
	my $curl = "curl -s --insecure -X GET -b cookies.txt $route_prefix/tools/public";
	my $result = `$curl`;
	$global_all_tools = from_json($result);
	foreach my $tool (@$global_all_tools) {
		# skip commercial tools
		next if ($tool->{'is_restricted'});
		$global_tool_uuid_to_name->{$tool->{'tool_uuid'}} = $tool->{'name'};
		foreach my $package_type (@{$tool->{'package_type_names'}}) {
			next if (! defined($package_type));
			my $package_type_id = $global_package_type_to_id->{$package_type};
			if ($package_type_id) {
				push @{$global_tools_by_package->{$package_type_id}}, $tool;
			}
		}
	}
	print "tool count: ", scalar(@$global_all_tools), "\n" if ($verbose);
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
--data \"project_owner_uid=${user_uuid}\&full_name=${full_name}\&short_name=${short_name}\&description=${description}\&affiliation=${affiliation}\&trial_project_flag=${trial_project_flag}\&exclude_public_tools_flag=${exclude_public_tools_flag}\" $route_prefix/projects";
	my $result = '{}';
	if (! $noexecute) {
		$result = `$curl`;
	}
	my $project = from_json($result);
	print "create_project result: $result\n" if ($verbose);
	return $project;
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
	my $affiliation = 'Morgridge Institute for Research';
	my $project = create_project_record($user_uuid, $full_name, $short_name, $description, $affiliation);
	$global_current_project = $project;
	my $project_uuid = $project->{'project_uid'} || '';
	return $project_uuid;
}

#################
#	Add Package	#
#################

sub add_package_record { my ($project_uuid, $package) = @_ ;
	$project_uuid = uri_escape($project_uuid);
	my $curl = "curl -s --insecure -X POST -b cookies.txt -F \"file=\@${package}\" $route_prefix/packages/versions/upload";
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
	my $ccurl = $curl . "\" $route_prefix/assessment_runs/check_compatibility";
	my $acurl = $curl . "\" $route_prefix/assessment_runs";
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
	my $projects = fetch_projects($user_uuid);
	my $i = 1;
	foreach my $project (@$projects) {
		print "$i) ", $project->{'full_name'}, ' [', $project->{'description'}, "]";
		print ' ', $project->{'project_uid'} if ($verbose);
		print "\n";
		$i += 1;
	}
}

sub show_all_platforms {
	foreach my $platform_uuid (sort {$global_platforms->{$a}->[0]->{'full_name'} cmp $global_platforms->{$b}->[0]->{'full_name'}} keys %$global_platforms) {
		my $platform_versions = $global_platforms->{$platform_uuid};
		(my $platform_name = $platform_versions->[0]->{'full_name'}) =~ s/ $platform_versions->[0]->{'version_string'}//;
		print $platform_name, ' [', scalar(@$platform_versions), ']';
		print ' ', $platform_uuid if ($verbose);
		print "\n";
		foreach my $platform_version (sort {$a->{'full_name'} cmp $b->{'full_name'}} @$platform_versions) {
			print '  ', $platform_version->{'platform_path'};
			print ' ', $platform_version->{'platform_version_uuid'} if ($verbose);
			print "\n";
		}
		print "\n";
	}
}

sub show_each_package_by_type { my ($packages) = @_ ;
	foreach my $package_type_id (sort {$a <=> $b} keys $packages) {
		print $package_type_id, ') ', $global_package_id_to_type->{$package_type_id}, ' [', scalar(@{$packages->{$package_type_id}}), "]\n";
		foreach my $package (@{$packages->{$package_type_id}}) {
			print "\t", $package->{'name'}, "\n";
		}
		print "\n";
	}
}

sub show_all_tools { my ($bypackage) = @_ ;
	if ($bypackage) {
		foreach my $package_type_id (sort {$a <=> $b} keys $global_tools_by_package) {
			print $package_type_id, ') ', $global_package_id_to_type->{$package_type_id}, ' [', scalar(@{$global_tools_by_package->{$package_type_id}}), "]\n";
			foreach my $tool (@{$global_tools_by_package->{$package_type_id}}) {
				print "\t", $tool->{'name'}, ' [', scalar(@{$tool->{'platform_names'}}), "]\n";
			}
			print "\n";
		}
	}
	else {
		foreach my $tool (@$global_all_tools) {
			print $tool->{'name'}, ' [', scalar(@{$tool->{'version_strings'}}), "]\n";
		}
		print "\n";
	}
}

sub show_all_package_types_for_tool {
	# sort the tools by the first package_type_id in the list
	foreach my $tool (sort {$global_package_type_to_id->{$a->{'package_type_names'}->[0]} <=> $global_package_type_to_id->{$b->{'package_type_names'}->[0]}} @$global_all_tools) {
		print $tool->{'name'}, ': ', join(', ', @{$tool->{'package_type_names'}}), "\n";
	}
}

sub show_current_project {
	print "\n", 'Current project: ', $global_current_project->{'short_name'}, "\n";
}

sub show_current_packages { my ($packages, $package_filter) = @_ ;
	print 'Current packages: ';
	foreach my $package_type_id (sort {$a <=> $b} keys $packages) {
		next if (! exists($package_filter->{$package_type_id}));
		my $first_package = $packages->{$package_type_id}->[0];
		my $package_name = $first_package->{'name'};
		my $package_type = $global_package_id_to_type->{$package_type_id};
		print $package_name, ' [', $package_type, '] ';
	}
	print "\n\n";
}

sub show_package_filter { my ($filter) = @_ ;
	print 'package type id filter [', scalar(keys %$filter), "]:\n  ", join(",  ", sort {"\L$a" cmp "\L$b"} map {$global_package_id_to_type->{$_}} sort {$a <=> $b} keys %$filter), "\n\n";
}

sub show_tool_filter { my ($filter) = @_ ;
	print 'tool filter [', scalar(keys %$filter), "]:\n  ", join(",  ", map {$global_tool_uuid_to_name->{$_}} sort {$filter->{$a} <=> $filter->{$b}} keys %$filter), "\n\n";
}

sub show_platform_version_filter { my ($filter) = @_ ;
	print 'platform version filter [', scalar(keys %$filter), "]:\n  ", join("\n  ", sort {"\L$a" cmp "\L$b"} map {$global_platform_version_uuid_to_name->{$_}} keys %$filter), "\n\n";
}

sub select_package_filter { my ($all, $packages) = @_ ;
	my $filter = {};
	if (! $all) {
		foreach my $package_type_id (sort {$a <=> $b} keys $packages) {
			print $package_type_id, ') ', $global_package_id_to_type->{$package_type_id}, "\n";
		}
		print 'Enter [<d>[,] ... <d>|A]: ';
		my $answer = <STDIN>;
		chomp $answer;
		print "answer: <$answer>\n" if ($debug);
		# select all package types
		if (! $answer || ($answer =~ m/^a$/i)) {
			$all = 1;
		}
		# select package types from list
		else {
			my @list = split ' ', $answer;
			foreach my $package_type_id (@list) {
				$package_type_id =~ s/,//;
				if (exists($packages->{$package_type_id})) {
					$filter->{$package_type_id} = 1;
				}
			}
		}
	}
	if ($all) {
		foreach my $package_type_id (sort {$a <=> $b} keys $packages) {
			$filter->{$package_type_id} = 1;
		}
	}
	return $filter;
}

sub refine_package_filter { my ($package_filter, $tool_filter) = @_ ;
	my $filter = {};
	# iterate over package type ids in tool filter
	# tool_filter is one-to-many so each tool_uuid has many package_type_ids
	foreach my $package_type_list (values %$tool_filter) {
		foreach my $package_type_id (@$package_type_list) {
			# if the package filter has package type id preserve it
			if (exists($package_filter->{$package_type_id})) {
				$filter->{$package_type_id} = 1;
			}
		}
	}
	return $filter;
}

# tool filter is a one-to-many map from tool_uuid to package_type_ids that tool will assess
# the filter is set up this way to make refinement based on package_filter work easily
sub select_tool_filter { my ($all, $packages) = @_ ;
	my $filter = {};
	if (! $all) {
		# iterate over only package type ids for which we have curated packages
		foreach my $package_type_id (sort {$a <=> $b} keys $packages) {
			print $package_type_id, ') ', $global_package_id_to_type->{$package_type_id}, ' [', scalar(@{$global_tools_by_package->{$package_type_id}}), "]\n";
			my $index = 1;
			foreach my $tool (@{$global_tools_by_package->{$package_type_id}}) {
				print '  ', $index++, ') ', $tool->{'name'}, "\n";
			}
			print 'Enter [<d>[,] .. <d>|p|a|N|q]: ';
			my $answer = <STDIN>;
			chomp $answer;
			print "answer: <$answer>\n" if ($debug);
			# select no tools for this package type
			next if (! $answer || ($answer =~ m/^n$/i));
			# finish selection
			last if ($answer =~ m/^q$/i);
			# select all tools for all package types
			if ($answer =~ m/^a$/i) {
				$all = 1;
				last;
			}
			# select all tools for current package type
			elsif ($answer =~ m/^p$/i) {
				foreach my $tool (@{$global_tools_by_package->{$package_type_id}}) {
					push @{$filter->{$tool->{'tool_uuid'}}}, $package_type_id;
				}
			}
			# select tools from list for current package type
			else {
				my @list = split ' ', $answer;
				map {s/,//;} @list;
				my %list = map {$_ => 1} @list;
				my $index = 1;
				foreach my $tool (@{$global_tools_by_package->{$package_type_id}}) {
					if (exists($list{$index})) {
						push @{$filter->{$tool->{'tool_uuid'}}}, $package_type_id;
					}
					$index += 1;
				}
			}
		}
	}
	if ($all || ! %$filter) {
		foreach my $package_type_id (sort {$a <=> $b} keys $global_tools_by_package) {
			foreach my $tool (@{$global_tools_by_package->{$package_type_id}}) {
				push @{$filter->{$tool->{'tool_uuid'}}}, $package_type_id;
			}
		}
	}
	return $filter;
}

sub refine_tool_filter { my ($tool_filter, $package_filter) = @_ ;
	my $filter = {};
	# iterate over tool uuids in tool filter
	foreach my $tool_uuid (keys %$tool_filter) {
		# if the tool has package_type_id from package_filter
		foreach my $package_type_id (@{$tool_filter->{$tool_uuid}}) {
			if (exists($package_filter->{$package_type_id})) {
				$filter->{$tool_uuid} = $package_type_id;
			}
		}
	}
	return $filter;
}

sub select_platform_version_filter { my ($all) = @_ ;
	my $filter = {};
	if (! $all) {
        foreach my $platform_uuid (sort {$global_platforms->{$a}->[0]->{'full_name'} cmp $global_platforms->{$b}->[0]->{'full_name'}} keys %$global_platforms) {
			my $platform_versions = $global_platforms->{$platform_uuid};
			(my $platform_name = $platform_versions->[0]->{'full_name'}) =~ s/ $platform_versions->[0]->{'version_string'}//;
			print $platform_name, ' [', scalar(@$platform_versions), "]\n";
			my $index = 1;
			foreach my $platform_version (sort {$a->{'full_name'} cmp $b->{'full_name'}} @$platform_versions) {
				print '  ', $index++, ') ', $platform_version->{'full_name'}, "\n";
			}
			print 'Enter [<d>[,] .. <d>|p|a|N|q]: ';
			my $answer = <STDIN>;
			chomp $answer;
			print "answer: <$answer>\n" if ($debug);
			# select no platform versions for this platform
			next if (! $answer);
			# finish selection
			last if ($answer =~ m/^q$/i);
			# select all versions for all platforms
			if ($answer =~ m/^a$/i) {
				$all = 1;
				last;
			}
			# select all versions for current platform
			elsif ($answer =~ m/^p$/i) {
				foreach my $platform_version (@$platform_versions) {
					$filter->{$platform_version->{'platform_version_uuid'}} = 1;
				}
			}
			# select versions from list for current platform
			else {
				my @list = split ' ', $answer;
				map {s/,//;} @list;
				my %list = map {$_ => 1} @list;
				my $index = 1;
				foreach my $platform_version (sort {$a->{'full_name'} cmp $b->{'full_name'}} @$platform_versions) {
					if (exists($list{$index})) {
						$filter->{$platform_version->{'platform_version_uuid'}} = 1;
					}
					$index += 1;
				}
			}
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

# one package of each package type (latest version)
# all tools applicable to package type (latest version)
# all platform versions
sub all_cross_product { my ($project_uuid, $package_filter, $tool_filter, $platform_version_filter, $packages) = @_ ;
	my $list_platforms = 0;
	if ($project_uuid eq 'v') {
		$list_platforms = 1;
		$project_uuid = '';
	}
	my $count = 0;
	foreach my $package_type_id (sort {$a <=> $b} keys $packages) {
		next if (! exists($package_filter->{$package_type_id}));
		my $first_package = $packages->{$package_type_id}->[0];
		my $package_name = $first_package->{'name'};
		my $package_uuid = $first_package->{'package_uuid'};
		my $package_version_uuid = ''; # always use latest package version
		print "package: $package_name";
		print " $package_uuid (", $global_package_id_to_type->{$package_type_id}, ')' if ($debug);
		print "\n";
		my $tools_for_package = $global_tools_by_package->{$package_type_id};
		foreach my $tool (@$tools_for_package) {
			my $tool_name = $tool->{'name'};
			my $tool_uuid = $tool->{'tool_uuid'};
			my $tool_version_uuid = ''; # always use latest tool version
			next if (! exists($tool_filter->{$tool_uuid}));
			print "  tool: $tool_name";
			print " $tool_uuid" if ($debug);
			print "\n" if ($list_platforms);
			my $platform_count = 0;
        	foreach my $platform_uuid (sort {$global_platforms->{$a}->[0]->{'full_name'} cmp $global_platforms->{$b}->[0]->{'full_name'}} keys %$global_platforms) {
				my $platform_versions = $global_platforms->{$platform_uuid};
                foreach my $platform_version (sort {$a->{'full_name'} cmp $b->{'full_name'}} @$platform_versions) {
					my $platform_name = $platform_version->{'full_name'};
					my $platform_version_uuid = $platform_version->{'platform_version_uuid'};
					next if (! exists($platform_version_filter->{$platform_version_uuid}));
					if ($list_platforms) {
						print "    platform: $platform_name";
						print " $platform_uuid ($platform_version_uuid)" if ($debug);
					}
					if ($project_uuid) {
						my ($status, $assessment_record_uuid) = 
							create_assessment_record($project_uuid, $package_uuid, $package_version_uuid, 
							$tool_uuid, $tool_version_uuid, $platform_uuid, $platform_version_uuid);
						print ' ', $status || $assessment_record_uuid;
					}
					print "\n" if ($list_platforms);
					$platform_count += 1;
					$count += 1;
				}
			}
			print " platform count: [$platform_count]\n" if (! $list_platforms);
		}
		print "\n";
	}
	print "Count: $count\n";
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

	['packagesbytypelist',		'list packages by package type'],
	['platformslist',			'list platforms with versions'],
	['alltoolslist',			'list all tools by name'],
	['toolsbypackagelist',		'list tools for each package type'],
	['packagetypetoolslist',	'list package types for each tool'],

	['ptfilter',				'set the package type filter'],
	['tfilter',					'set the tool filter'],
	['pvfilter',				'set the platform version filter'],

	['projectslist',			'list all projects for user'],
	['createproject',			'create a new project'],
	['selectproject',			'select project from a list'],

	['listcrossproduct',		'list cross product entries with platform version count'],
	['vlistcrossproduct',		'list cross product entries with platform version names'],
	['createcrossproduct',		'create cross product package x tool x platform version assessment records'],
];
my $max_command_length = 0;
foreach my $command (@$commands) {
	my $length = length($command->[0]);
	$max_command_length = $length if ($length > $max_command_length);
}

sub menu_driver { my ($user_uuid) = @_ ;
	# default project to MyProject
	my $project_uuid = select_project($user_uuid, 1);
	# default to user packages with associated package and tool filters
	my $packages = $global_user_packages;
	if (! %$packages) {
		$packages = $global_curated_packages;
	}
	my $package_filter = select_package_filter(1, $packages);
	my $tool_filter = select_tool_filter(1, $packages);
	my $platform_version_filter = select_platform_version_filter(1);
	my $show_filters = 1;
	while (1) {
		show_current_project();
		show_current_packages($packages, $package_filter);
		if ($show_filters) {
			show_package_filter($package_filter);
			show_tool_filter($tool_filter);
			show_platform_version_filter($platform_version_filter);
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
			if ($packages ne $global_curated_packages) {
				$packages = $global_curated_packages;
				$package_filter = select_package_filter(1, $packages);
				$tool_filter = select_tool_filter(1, $packages);
			}
		}
		elsif ('selectuserpackages' =~ m/^$answer/i) {
			if ($packages ne $global_user_packages) {
				$packages = $global_user_packages;
				$package_filter = select_package_filter(1, $packages);
				$tool_filter = select_tool_filter(1, $packages);
			}
		}
		elsif ('packagesbytypelist' =~ m/^$answer/i) {
			show_each_package_by_type($packages);
			$show_filters = 0;
		}
		elsif ('platformslist' =~ m/^$answer/i) {
			show_all_platforms();
			$show_filters = 0;
		}
		elsif ('alltoolslist' =~ m/^$answer/i) {
			show_all_tools(0);
			$show_filters = 0;
		}
		elsif ('toolsbypackagelist' =~ m/^$answer/i) {
			show_all_tools(1);
			$show_filters = 0;
		}
		elsif ('packagetypetoolslist' =~ m/^$answer/i) {
			show_all_package_types_for_tool();
			$show_filters = 0;
		}
		elsif ('ptfilter' =~ m/^$answer/i) {
			$package_filter = select_package_filter(0, $packages);
			$tool_filter = refine_tool_filter($tool_filter, $package_filter);
			# if tool filter is reduced to null - recompute it from full refined by package filter
			if (! %$tool_filter) {
				$tool_filter = refine_tool_filter(select_tool_filter(1, $packages), $package_filter);
			}
		}
		elsif ('tfilter' =~ m/^$answer/i) {
			$tool_filter = select_tool_filter(0, $packages);
			$package_filter = refine_package_filter($package_filter, $tool_filter);
			# if package filter is reduced to null - recompute it from full refined by tool filter
			if (! %$tool_filter) {
				$package_filter = refine_package_filter(select_package_filter(1, $packages), $tool_filter);
			}
		}
		elsif ('pvfilter' =~ m/^$answer/i) {
			$platform_version_filter = select_platform_version_filter(0);
		}
		elsif ('projectslist' =~ m/^$answer/i) {
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
			all_cross_product('', $package_filter, $tool_filter, $platform_version_filter, $packages);
		}
		elsif ('vlistcrossproduct' =~ m/^$answer/i) {
			all_cross_product('v', $package_filter, $tool_filter, $platform_version_filter, $packages);
		}
		elsif ('createcrossproduct' =~ m/^$answer/i) {
			all_cross_product($project_uuid, $package_filter, $tool_filter, $platform_version_filter, $packages);
		}
		elsif ('addpackage' =~ m/^$answer/i) {
			add_package($project_uuid);
		}
	}
}

sub usage {
	print "usage: $0 [-help -debug -verbose -quiet -noexecute]\n";
	exit;
}

my $help = 0;
my $result = GetOptions(
	'help'			=> \$help,
	'debug'			=> \$debug,
	'verbose'		=> \$verbose,
	'quiet'			=> \$quiet,
	'noexecute'		=> \$noexecute,
	'server=s'		=> \$swampserver,
	'username=s'	=> \$username,
	'password=s'	=> \$password,
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
$route_prefix = set_route_prefix($swampserver);
if (! $route_prefix) {
	print "Error - could not set route_prefix for: $swampserver\n";
	exit(0);
}
print "route_prefix for $swampserver: $route_prefix\n" if ($debug);
if (! $username) {
	print 'Enter username: ';
	$username = <STDIN>;
	chomp $username;
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
