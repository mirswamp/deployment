#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

use strict;
use warnings;
use FindBin;
use Cwd;

my $verbose = 0;
my $workspace;
foreach my $arg (@ARGV) {
	if (-d $arg) {
		$workspace = $arg;
	}
	elsif ($arg =~ m/^-v/) {
		$verbose = 1;
	}
}

sub git_branch { my ($dir) = @_ ;
	my $cwd = getcwd();
	print "$dir: ";
	chdir $dir;
	# print 'git_branch - change to: ', $dir, "\n";
	my $result = `git status --untracked-files=no`;
	if ($verbose) {
		print $result, "\n";
	}
	else {
		if ($result =~ m/On branch\s*(.*)$/m) {
			print $1, "\n";
		}
		else {
			print "N/A\n";
		}
	}
	chdir $cwd;
	# print 'git_branch - change back: ', $cwd, "\n";
}

sub git_branch_dirs { my ($dir) = @_ ;
	my $cwd = getcwd();
	# print 'dir: ', $dir, ' cwd: ', $cwd, "\n";
	chdir $dir;
	# print 'git_branch_dirs - change to: ', $dir, "\n";
	my @dirs = `ls`;
	chomp(@dirs);
	# print 'dirs: ', (join ',', @dirs), "\n";
	foreach my $subdir (@dirs) {
		if (-d $subdir) {
			if (-r "$subdir/.git") {
				git_branch($subdir);
			}
			else {
				git_branch_dirs($subdir);
			}
		}
	}
	chdir $cwd;
	# print 'git_branch_dirs - change back: ', $cwd, "\n";
}

if (! defined($workspace)) {
	$workspace = "$FindBin::Bin/../../../../";
}
print "Showing git status for: $workspace\n";
git_branch_dirs($workspace);
print "Hello World!\n";
