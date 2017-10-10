#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

#
# Check whether the current host has enough disk space, memory,
# and cores for SWAMP-in-a-Box to perform acceptably.
#

#
# For 'perlcritic': The "magic" numbers are being assigned to what are
# effectively constants. Not using the 'constant' pragma because the
# constants defined with it don't use sigils. Not following the other
# recommendations because they involve non-core modules.
#
## no critic (MagicNumbers, NumberSeparators, RequireDotMatchAnything, RequireLineBoundaryMatching, RequireExtendedFormatting)
#

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
my $MEM_MUST_PASS   = 1;
my $DISK_MUST_PASS  = 1;

#
# Each VM requires 2 cores and 6 GB of RAM.
# We want the system to support 2 VMs running simultaneously.
#
my $CORES_PER_VM       = 2;
my $MEM_PER_VM         = 6144;
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
    '1.31'   => 11786,
);
my %tools_sizes = (
    '1.27.1' => 2557,
    '1.27.2' => 2557,
    '1.28.1' => 4874,
    '1.29'   => 5111,
    '1.30'   => 5117,
    '1.31'   => 5200,
);

#
# For each mount point where we need to install files, we'll leave a 1 GB
# margin for error for how much free space we think is required.
#
my $DISK_SPACE_PADDING = 1024;

my $PLATFORMS_DIR     = '/swamp/platforms/images';
my $TOOLS_DIR         = '/swamp/store/SCATools';
my $PERL_RT_DIR       = '/opt';
my $SWAMP_BACKEND_DIR = '/opt';
my $SWAMP_WEB_DIR     = '/var/www';

my $PERL_RT_RPM       = 'swamp-rt-perl';
my $SWAMP_BACKEND_RPM = 'swampinabox-backend';
my $SWAMP_WEB_RPM     = 'swamp-web-server';

#
# Track how much space is required on each mount point.
#
my %required_space;

############################################################################
#
# Define and process command-line options.
#
my $is_install      = 0;
my $is_upgrade      = 0;
my $is_distribution = 0;
my $is_singleserver = 0;
my $rpms_dir        = q();
my $version         = q();
my $raw_version     = q();

Getopt::Long::Configure('bundling_override');
Getopt::Long::GetOptions(
    'install'      => \$is_install,
    'upgrade'      => \$is_upgrade,
    'distribution' => \$is_distribution,
    'singleserver' => \$is_singleserver,
    'rpms=s'       => \$rpms_dir,
    'version=s'    => \$raw_version,
);

$version = strip_version_suffix($raw_version);

if ((!$is_install && !$is_upgrade) || ($is_install && $is_upgrade)) {
    die "Error: $PROGRAM_NAME: Exactly one of -install and -upgrade must be specified\n";
}
if ((!$is_distribution && !$is_singleserver) || ($is_distribution && $is_singleserver)) {
    die "Error: $PROGRAM_NAME: Exactly one of -distribution and -singleserver must be specified\n";
}
if ($is_distribution) {
    if (!-d $rpms_dir) {
        die "Error: $PROGRAM_NAME: With -distribution, -rpms must be specified and point to a directory\n";
    }
    if (!$version) {
        die "Error: $PROGRAM_NAME: With -distribution, -version must be specified\n";
    }
    if (!$platforms_sizes{$version} || !$tools_sizes{$version}) {
        die "Error: $PROGRAM_NAME: Version not recognized: $raw_version\n";
    }
}

############################################################################
#
# Go through the checklist.
#
determine_required_disk_space();
check_for_cores();
check_for_physical_mem();

if ($is_distribution) {
    check_for_static_disk_space();
}

#
# Check that an install vs. upgrade is appropriate.
#
my $current_version = strip_version_suffix(get_rpm_version($SWAMP_WEB_RPM, 1));

if ($is_install && $current_version) {
    print "\n";
    print "SWAMP-in-a-Box version $current_version appears to be installed.\n";
    print "Performing an install will erase existing data and configuration.\n";
    print "\n";
    print "Are you sure you want to install version $version? [N/y] ";

    my $answer = <>;
    chomp $answer;

    if ($answer ne 'y') {
        exit 1;
    }
}

if ($is_upgrade && !$current_version) {
    print "Error: Did not find a SWAMP-in-a-Box installation to upgrade.\n";
    exit 1;
}

if ($is_upgrade && $current_version =~ m/^(1\.27|1\.28)/) {
    print "Error: Upgrading from $current_version is not supported.\n";
    exit 1;
}

exit 0;

############################################################################

sub get_num_cores {
    open(my $fh, '<', '/proc/cpuinfo')
      || die "Error: $PROGRAM_NAME: Unable to open /proc/cpuinfo\n";
    my $num_processors = grep { /^(processor)\s*:/ixms } (<$fh>);
    close $fh;
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
        if (!-e $test_path && -l $test_path) {
            die "Error: $test_path is a symlink that points to nothing.\n";
        }
        if (-e $test_path && !-d $test_path) {
            die "Error: $test_path is not a directory.\n";
        }
        if (-e $test_path) {
            my $mount_point = `df -P $test_path | tail -n 1 | awk '{print \$6}'`;
            if ($CHILD_ERROR) {
                die "Error: $PROGRAM_NAME: Unexpected failure of subcommand.\n";
            }
            chomp $mount_point;
            return $mount_point;
        }
        pop @dirs;
    }
    return q();
}

sub get_free_space {
    my ($path) = @_;

    if (!-e $path) {
        return 0;
    }

    my $free_space = `df -P -B 1M $path | tail -n 1 | awk '{print \$4}'`;
    if ($CHILD_ERROR) {
        die "Error: $PROGRAM_NAME: Unexpected failure of subcommand.\n";
    }
    chomp $free_space;
    return $free_space;
}

sub get_rpm_info {
    my ($package_name, $field, $assume_installed) = @_;
    my $rpm_name    = q();
    my $other_flags = q();

    if ($assume_installed) {
        $rpm_name    = $package_name;
        $other_flags = q();
    }
    else {
        $rpm_name    = (glob "$rpms_dir/$package_name*")[0];
        $other_flags = '-p';
    }

    my $info = qx(rpm -q --queryformat '%{$field}' $other_flags $rpm_name 2>/dev/null);
    return ($info, $CHILD_ERROR);
}

sub get_rpm_size {
    my ($package_name, $assume_installed) = @_;
    my ($size_in_bytes, $error) = get_rpm_info($package_name, 'SIZE', $assume_installed);

    if ($error) {
        $size_in_bytes = 0;
    }
    chomp $size_in_bytes;
    return $size_in_bytes / 1024 / 1024;
}

sub get_rpm_version {
    my ($package_name, $assume_installed) = @_;
    my ($version_string, $error) = get_rpm_info($package_name, 'VERSION', $assume_installed);

    if ($error) {
        $version_string = q();
    }
    chomp $version_string;
    return $version_string;
}

sub strip_version_suffix {
    my ($str) = @_;
    if ($str =~ /^(\d+ [.] \d+ ([.] \d+)?)/x) {
        $str = $1;
    }
    return $str;
}

sub sum_of_meminfo {
    my ($labels) = @_;
    my @meminfo;

    open(my $fh, '<', '/proc/meminfo')
      || die "Error: $PROGRAM_NAME: Unable to open /proc/meminfo\n";
    @meminfo = grep { /^($labels)\s*:/i } (<$fh>);
    close $fh;

    @meminfo = map  { split /\s+/ } @meminfo;
    @meminfo = grep { looks_like_number($_) } @meminfo;

    my $total_in_kB = sum(@meminfo);
    return int($total_in_kB / 1024);
}

sub determine_required_disk_space {
    #
    # For the moment, assume that the installation needs to fit on disk
    # alongside whatever is currently installed.
    #
    $required_space{get_mount_point($PLATFORMS_DIR)}     += $platforms_sizes{$version};
    $required_space{get_mount_point($TOOLS_DIR)}         += $tools_sizes{$version};
    $required_space{get_mount_point($PERL_RT_DIR)}       += get_rpm_size($PERL_RT_RPM, 0);
    $required_space{get_mount_point($SWAMP_BACKEND_DIR)} += get_rpm_size($SWAMP_BACKEND_RPM, 0);
    $required_space{get_mount_point($SWAMP_WEB_DIR)}     += get_rpm_size($SWAMP_WEB_RPM, 0);
    return;
}

############################################################################

sub check_for_cores {
    my $available = get_num_cores();
    my $required  = $CORES_PER_VM * $NUM_CONCURRENT_VMS;

    if ($available < $required) {
        print "Error: Looking for $required cores ... found only $available\n";
        exit 1 if $CORES_MUST_PASS;
    }
    else {
        print "Looking for $required cores ... found $available\n";
    }
    return;
}

sub check_for_free_mem {
    my $available = get_free_mem();
    my $required  = $MEM_PER_VM * $NUM_CONCURRENT_VMS;

    if ($available < $required) {
        print "Error: Looking for $required MB free RAM ... found only $available MB\n";
        exit 1 if $MEM_MUST_PASS;
    }
    else {
        print "Looking for $required MB free RAM ... found $available MB\n";
    }
    return;
}

sub check_for_physical_mem {
    my $available = get_physical_mem();
    my $required  = $MEM_PER_VM * $NUM_CONCURRENT_VMS + $ADDITIONAL_MEM_NEEDS;

    if ($available < $required) {
        print "Error: Looking for $required MB physical RAM ... found only $available MB\n";
        exit 1 if $MEM_MUST_PASS;
    }
    else {
        print "Looking for $required MB physical RAM ... found $available MB\n";
    }
    return;
}

sub check_for_static_disk_space {
    my $check_failed;

    #
    # Print out the mount points that have sufficient space available
    # before printing out the ones that do not.
    #
    for my $mount_point (keys %required_space) {
        my $required  = int($required_space{$mount_point} + $DISK_SPACE_PADDING);
        my $available = int(get_free_space($mount_point));

        if ($available >= $required) {
            print "Looking for $required MB space free on '$mount_point' ... found $available MB\n";
        }
    }
    for my $mount_point (keys %required_space) {
        my $required  = int($required_space{$mount_point} + $DISK_SPACE_PADDING);
        my $available = int(get_free_space($mount_point));

        if ($available < $required) {
            print "Error: Looking for $required MB space free on '$mount_point' ... found only $available MB\n";
            $check_failed = 1;
        }
    }

    if ($check_failed) {
        exit 1 if $DISK_MUST_PASS;
    }
    return;
}
