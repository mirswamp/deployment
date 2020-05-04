#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

#
# Check whether the current host has enough disk space, memory,
# and cores for SWAMP-in-a-Box to perform acceptably.
#

#
# For 'perlcritic'.
#
## no critic (MagicNumbers, RequireDotMatchAnything, RequireLineBoundaryMatching, RequireExtendedFormatting)

use utf8;
use strict;
use warnings;

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
my $MEM_PER_VM         = 6 * 1024;
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
# These values are in MB. They were computed with `du -sm` and rounded up.
#
my $platforms_size = 16_000;
my $tools_size     = 5_500;

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
# Process command-line options.
#
my $is_install      = 0;
my $is_upgrade      = 0;
my $is_distribution = 0;
my $is_singleserver = 0;
my $rpms_dir        = q();

Getopt::Long::Configure('bundling_override');    # allow, for example, -install
Getopt::Long::GetOptions(
    'install'      => \$is_install,
    'upgrade'      => \$is_upgrade,
    'distribution' => \$is_distribution,
    'singleserver' => \$is_singleserver,
    'rpms-dir=s'   => \$rpms_dir,
);

############################################################################
#
# Check the available hardware resources.
#
determine_required_disk_space();
check_for_cores();
check_for_physical_mem();
check_for_static_disk_space() if $is_distribution;
exit 0;

############################################################################

sub get_num_cores {
    open(my $fh, '<', '/proc/cpuinfo')
      || die "Error: Failed to open: /proc/cpuinfo\n";
    my $num_processors = grep { /^(processor)[[:space:]]*:/i } (<$fh>);
    close($fh)
      || die "Error: Failed to close: /proc/cpuinfo\n";
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

    #
    # Find the longest prefix of $path that actually exists.
    # Then use 'df' to get its corresponding mount point.
    #
    while (@dirs) {
        my $test_path = File::Spec->catdir(@dirs);
        if (!-e $test_path && -l $test_path) {
            die "Error: Symbolic link that points to nothing: $test_path\n";
        }
        if (-e $test_path && !-d $test_path) {
            die "Error: Not a directory: $test_path\n";
        }
        if (-e $test_path) {
            my $path_arg = make_shell_arg($test_path);
            my $mount_point = qx(df -P $path_arg | tail -n 1 | awk '{print \$6}');
            if ($CHILD_ERROR) {
                die "Error: Unexpected failure of subcommand\n";
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

    my $path_arg = make_shell_arg($path);
    my $free_space = qx(df -P -B 1M $path_arg | tail -n 1 | awk '{print \$4}');
    if ($CHILD_ERROR) {
        die "Error: Unexpected failure of subcommand\n";
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
        my $pattern = File::Spec->catfile($rpms_dir, "$package_name*");
        $rpm_name = (glob $pattern)[0] || q();
        $other_flags = '-p';
    }

    my $pkg_arg = make_shell_arg($rpm_name);
    my $info = qx(rpm -q --queryformat '%{$field}' $other_flags $pkg_arg 2>/dev/null);
    return ($info, $CHILD_ERROR);
}

sub get_rpm_size {
    my ($package_name, $assume_installed) = @_;
    my ($size_in_bytes, $error) = get_rpm_info($package_name, 'SIZE', $assume_installed);

    if ($error || !looks_like_number($size_in_bytes)) {
        $size_in_bytes = 0;
    }
    chomp $size_in_bytes;
    return $size_in_bytes / 1024 / 1024;
}

############################################################################

sub make_shell_arg {
    my ($arg) = @_;
    if (defined $arg) {
        $arg =~ s/'/'\\''/g;
        $arg = qq('$arg');
    }
    return $arg;
}

sub sum_of_meminfo {
    my ($labels) = @_;
    my @meminfo;

    open(my $fh, '<', '/proc/meminfo')
      || die "Error: Failed to open: /proc/meminfo\n";
    @meminfo = grep { /^($labels)[[:space:]]*:/i } (<$fh>);
    close($fh)
      || die "Error: Failed to close: /proc/meminfo\n";

    @meminfo = map  { split /[[:space:]]+/ } @meminfo;
    @meminfo = grep { looks_like_number($_) } @meminfo;

    my $total_in_kilobytes = sum(@meminfo);
    return int($total_in_kilobytes / 1024);
}

############################################################################

sub determine_required_disk_space {
    #
    # For the moment, assume that the installation needs to fit on disk
    # alongside whatever is currently installed.
    #
    $required_space{get_mount_point($PLATFORMS_DIR)}     += $platforms_size;
    $required_space{get_mount_point($TOOLS_DIR)}         += $tools_size;
    $required_space{get_mount_point($PERL_RT_DIR)}       += get_rpm_size($PERL_RT_RPM, 0);
    $required_space{get_mount_point($SWAMP_BACKEND_DIR)} += get_rpm_size($SWAMP_BACKEND_RPM, 0);
    $required_space{get_mount_point($SWAMP_WEB_DIR)}     += get_rpm_size($SWAMP_WEB_RPM, 0);
    return;
}

sub check_for_cores {
    my $available = get_num_cores();
    my $required  = $CORES_PER_VM * $NUM_CONCURRENT_VMS;

    print "Looking for $required cores ... found $available\n";

    if ($available < $required) {
        print "\n";
        print "Error: Found only $available cores, require $required\n";
        exit 1 if $CORES_MUST_PASS;
    }
    return;
}

sub check_for_physical_mem {
    my $available = get_physical_mem();
    my $required  = $MEM_PER_VM * $NUM_CONCURRENT_VMS + $ADDITIONAL_MEM_NEEDS;

    print "Looking for $required MB physical RAM ... found $available MB\n";

    if ($available < $required) {
        print "\n";
        print "Error: Found only $available MB physical RAM, require $required MB\n";
        exit 1 if $MEM_MUST_PASS;
    }
    return;
}

sub check_for_static_disk_space {
    my $check_failed = 0;

    for my $mount_point (keys %required_space) {
        my $required  = int($required_space{$mount_point} + $DISK_SPACE_PADDING);
        my $available = int(get_free_space($mount_point));

        print "Looking for $required MB space free on '$mount_point' ... found $available MB\n";

        if ($available < $required) {
            $check_failed = 1;
        }
    }

    if ($check_failed) {
        print "\n";
        print "Error: Not all mount points have enough space free\n";
        exit 1 if $DISK_MUST_PASS;
    }
    return;
}
