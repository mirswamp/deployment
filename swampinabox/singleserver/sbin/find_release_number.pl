#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

use strict;
use warnings;

my $workspace;
my $findmax = 0;
my $install = 1;
foreach my $arg (@ARGV) {
	if ($arg eq '-upgrade') {
		$install = 0;
	}
	elsif ($arg eq '-install') {
		$install = 1;
	}
	elsif ($arg eq '-findmax') {
		$findmax = 1;
	}
	else {
		$workspace = $arg;
	}
}

sub find_release_number_in_workspace { my ($workspace) = @_ ;
	my @rpms = `find $workspace -name '*.rpm'`;
	chomp @rpms;
	my %release_number = ();
	foreach my $rpm (@rpms) {
		if ($rpm =~ m/^.*\-(.*)\-dev.noarch.rpm$/) {
			my $release_number = $1;
			$release_number{$release_number} += 1;
		}
	}
	my $release_number = '';
	if ($findmax) {
		my $maxkey = '';
		my $maxkey_parts = [];
		foreach my $key (sort keys %release_number) {
			if (! $maxkey) {
				$maxkey = $key;
				$maxkey_parts = [split '\.', $maxkey];
				next;
			}
			my @key_parts = split '\.', $key;
			for (my $i = 0; $i < $#key_parts; $i++) {
				if ($key_parts[$i] =~ m/^\d+$/) {
					if ($key_parts[$i] > $$maxkey_parts[$i]) {
						$maxkey_parts = \@key_parts;
						$maxkey = $key;
						last;
					}
				}
			}
		}
		$release_number = $maxkey;
	}
	else {
		if (scalar(keys %release_number) == 1) {
			# release number is singular existing key
			$release_number = (keys %release_number)[0];
			# release number is void if count for key does not equal rpm count
			$release_number = '' if ($release_number{$release_number} != scalar(@rpms));
		}
	}
	return $release_number;
}

sub find_release_number_in_installed {
	my $line = `yum list installed 2>/dev/null | grep -i swampinabox`;
	chomp $line;
	my @parts = split ' ', $line;
	my $release_number = $parts[1] || '';
	if ($release_number) {
		my @parts = split '-', $release_number;
		$parts[1] += 1 if ((scalar(@parts) == 2) && ($parts[1] =~ m/^\d+$/));
		$release_number = join '-', @parts;
	}
	return $release_number;
}

my $release_number = find_release_number_in_installed();
print $release_number;
