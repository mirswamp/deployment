#!/usr/bin/env perl
# vim: textwidth=110

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

use utf8;
use strict;
use warnings;

use Cwd qw(realpath);
use English qw( -no_match_vars );
use File::Spec;
use Getopt::Long;
use List::Util qw(sum);
use Scalar::Util qw(looks_like_number);

#
# By default, all of the checks performed by this script must pass.
# However, some of them can be bypassed by setting the following to 0.
#
my $CORES_MUST_PASS = 1;
my $MEM_MUST_PASS = 1;
my $DISK_MUST_PASS = 1;

#
# Each VM requires 2 cores and 6 GB of RAM.
# We want the system to support 2 VMs running simultaneously.
#
my $CORES_PER_VM = 2;
my $MEM_PER_VM = 6144;
my $NUM_CONCURRENT_VMS = 2;

#
# We also need to have memory available to run everything else.
# For the moment, we'll arbitrarily pick 1 GB.
#
my $ADDITIONAL_MEM_NEEDS = 1024;

#
# tar and gzip don't allow us to accurately compute uncompressed, extracted
# file sizes without actually expanding the archives. Thus, we'll hard code
# the amount of space that we expect to be taken by the platforms and tools.
#
# These values are in MB. They were computed with `du -sm`.
#
my %platforms_sizes = (
    '1.27.1' => 38825,
    '1.27.2' => 38825,
    '1.28.1' => 11881,
    '1.29'   => 11881,
    '1.30'   => 11881,
);
my %tools_sizes = (
    '1.27.1' => 2557,
    '1.27.2' => 2557,
    '1.28.1' => 4874,
    '1.29'   => 5111,
    '1.30'   => 5117,
);

#
# For each mount point where we need to install files, we'll leave a 1 GB
# margin for error for how much free space we think is required.
#
my $DISK_SPACE_PADDING  = 1024;

my $PLATFORMS_DIR       = '/swamp/platforms/images';
my $TOOLS_DIR           = '/swamp/store/SCATools';
my $JAVA_RT_DIR         = '/opt';
my $PERL_RT_DIR         = '/opt';
my $SWAMP_BACKEND_DIR   = '/opt';
my $SWAMP_WEB_DIR       = '/var/www';

my $JAVA_RT_RPM         = 'swamp-rt-java';
my $PERL_RT_RPM         = 'swamp-rt-perl';
my $SWAMP_BACKEND_RPM   = 'swampinabox-backend';
my $SWAMP_WEB_RPM       = 'swamp-web-server';

#
# Track how much space is required on each mount point.
#
my %required_space;

############################################################################
#
# Define and process command-line options.
#
my $is_install       = 0;
my $is_upgrade       = 0;
my $is_distribution  = 0;
my $is_singleserver  = 0;
my $rpms             = q{};
my $version          = q{};
my $raw_version      = q{};

Getopt::Long::Configure('bundling_override');
Getopt::Long::GetOptions(
    'install'       => \$is_install,
    'upgrade'       => \$is_upgrade,
    'distribution'  => \$is_distribution,
    'singleserver'  => \$is_singleserver,
    'rpms=s'        => \$rpms,
    'version=s'     => \$raw_version,
);

$version = strip_version_suffix($raw_version);

if ((!$is_install && !$is_upgrade) || ($is_install && $is_upgrade)) {
    print "\n$0: Error: Exactly one of -install and -upgrade must be specified\n";
    exit 1;
}
if ((!$is_distribution && !$is_singleserver) || ($is_distribution && $is_singleserver)) {
    print "\n$0: Error: Exactly one of -distribution and -singleserver must be specified\n";
    exit 1;
}
if ($is_distribution) {
    if (! -d $rpms) {
        print "\n$0: Error: With -distribution, -rpms must be specified and point to a directory\n";
        exit 1;
    }
    if (!$version) {
        print "\n$0: Error: With -distribution, -version must be specified\n";
        exit 1;
    }
    if (!$platforms_sizes{$version} || !$tools_sizes{$version}) {
        print "\n$0: Error: $raw_version is not a recognized version\n";
        exit 1;
    }
}

############################################################################
#
# Go through checklist.
#
determine_required_disk_space();
check_for_cores();
check_for_physical_mem();

if ($is_distribution) {
    check_for_static_disk_space();
}

if ($is_upgrade && get_rpm_size('swamp-web-server', 1) <= 0) {
    print "Error: No SWAMP-in-a-Box installation to upgrade.\n";
    print "Run the install script to set up a new SWAMP-in-a-Box installation.\n";
    exit 1;
}

exit 0;

############################################################################

sub get_num_cores {
    open(my $fh, '<', '/proc/cpuinfo')
        || die '$0: Error: Unable to open /proc/cpuinfo, stopping';
    my $num_processors = grep { /^(processor)\s*:/i } (<$fh>);
    return $num_processors;
}

sub get_free_mem {
    return sum_of_meminfo('MemFree|Buffers|Cached');
}

sub get_physical_mem {
    return sum_of_meminfo('MemTotal');
}

sub get_mount_point {
    my ($path) = @_;
    my @dirs = File::Spec->splitdir(File::Spec->canonpath($path));

    while (@dirs) {
        my $test_path = File::Spec->catdir(@dirs);
        if (! -e $test_path && -l $test_path) {
            print "\nError: $test_path is a symlink that points to nothing.\n";
            exit 1;
        }
        if (-e $test_path && ! -d $test_path) {
            print "\nError: $test_path is not a directory.\n";
            exit 1;
        }
        if (-e $test_path) {
            my $mount_point = `df -P $test_path | tail -n 1 | awk '{print \$6}'`;
            if ($CHILD_ERROR) {
                print "\nError: Unexpected failure of subcommand.\n";
                exit 1;
            }
            chomp $mount_point;
            return $mount_point;
        }
        pop @dirs;
    }
    return q{};
}

sub get_free_space {
    my ($path) = @_;

    if (! -e $path) {
        return 0;
    }

    my $free_space = `df -P -B 1M $path | tail -n 1 | awk '{print \$4}'`;
    if ($CHILD_ERROR) {
        print "\nError: Unexpected failure of subcommand.\n";
        exit 1;
    }
    chomp $free_space;
    return $free_space;
}

sub get_rpm_size {
    my ($package_name, $assume_installed) = @_;
    my $rpm_name     = q{};
    my $other_flags  = q{};

    if ($assume_installed) {
        $rpm_name = $package_name;
        $other_flags = q{};
    }
    else {
        $rpm_name = (glob "$rpms/$package_name*")[0];
        $other_flags = '-p';
    }

    my $size_in_bytes = `rpm -q --queryformat '%{SIZE}' $other_flags $rpm_name 2>/dev/null`;
    if ($CHILD_ERROR) {
        $size_in_bytes = 0;
    }
    chomp $size_in_bytes;
    return $size_in_bytes / 1024 / 1024;
}

sub strip_version_suffix {
    my ($version) = @_;
    if ($version =~ /^(\d+\.\d+(\.\d+)?)/) {
        $version = $1;
    }
    return $version;
}

sub sum_of_meminfo {
    my ($labels) = @_;

    open(my $fh, '<', '/proc/meminfo')
        || die '$0: Error: Unable to open /proc/meminfo, stopping';

    my @meminfo;
    @meminfo = grep { /^($labels)\s*:/i } (<$fh>);
    @meminfo = map { split /\s+/ } @meminfo;
    @meminfo = grep { looks_like_number($_) } @meminfo;

    my $total_in_kB = sum(@meminfo);
    return $total_in_kB / 1024;
}

sub determine_required_disk_space {
    #
    # For the moment, assume that the installation needs to fit on disk
    # alongside whatever is currently installed.
    #
    $required_space{get_mount_point($PLATFORMS_DIR)}      += $platforms_sizes{$version};
    $required_space{get_mount_point($TOOLS_DIR)}          += $tools_sizes{$version};
    $required_space{get_mount_point($JAVA_RT_DIR)}        += get_rpm_size($JAVA_RT_RPM, 0);
    $required_space{get_mount_point($PERL_RT_DIR)}        += get_rpm_size($PERL_RT_RPM, 0);
    $required_space{get_mount_point($SWAMP_BACKEND_DIR)}  += get_rpm_size($SWAMP_BACKEND_RPM, 0);
    $required_space{get_mount_point($SWAMP_WEB_DIR)}      += get_rpm_size($SWAMP_WEB_RPM, 0);
}

############################################################################

sub check_for_cores {
    my $available = get_num_cores();
    my $required = $CORES_PER_VM * $NUM_CONCURRENT_VMS;

    if ($available < $required) {
        print "\nError: Found only $available cores.\n";
        print "SWAMP-in-a-Box requires $required cores to perform acceptably.\n";
        exit 1 if $CORES_MUST_PASS;
    }
}

sub check_for_free_mem {
    my $available = get_free_mem();
    my $required = $MEM_PER_VM * $NUM_CONCURRENT_VMS;

    if ($available < $required) {
        print "\nError: Found only $available MB of free RAM.\n";
        print "SWAMP-in-a-Box requires $required MB to perform acceptably.\n";
        exit 1 if $MEM_MUST_PASS;
    }
}

sub check_for_physical_mem {
    my $available = get_physical_mem();
    my $required = $MEM_PER_VM * $NUM_CONCURRENT_VMS + $ADDITIONAL_MEM_NEEDS;

    if ($available < $required) {
        print "\nError: Found only $available MB of physical RAM.\n";
        print "SWAMP-in-a-Box requires $required MB to perform acceptably.\n";
        exit 1 if $MEM_MUST_PASS;
    }
}

sub check_for_static_disk_space {
    my $check_failed;

    print "\n";

    #
    # Print out the mount points that have sufficient space available
    # before printing out the ones that do not.
    #
    for my $mount_point (keys(%required_space)) {
        my $required  = int($required_space{$mount_point} + $DISK_SPACE_PADDING);
        my $available = int(get_free_space($mount_point));

        if ($available >= $required) {
            print "Looking for $required MB space free on '$mount_point'. Found $available MB.\n";
        }
    }
    for my $mount_point (keys(%required_space)) {
        my $required  = int($required_space{$mount_point} + $DISK_SPACE_PADDING);
        my $available = int(get_free_space($mount_point));

        if ($available < $required) {
            print "Error: Looking for $required MB space free on '$mount_point'. Found only $available MB.\n";
            $check_failed = 1;
        }
    }

    if ($check_failed) {
        exit 1 if $DISK_MUST_PASS;
    }
}
