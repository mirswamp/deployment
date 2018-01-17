#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

#
# Patch php.ini for SWAMP-in-a-Box.
# Specifically, enable "large" uploads.
#

use utf8;
use strict;
use warnings;

use English qw( -no_match_vars );
use POSIX qw(strftime);

#
# Check for required command-line arguments.
#

if (scalar(@ARGV) <= 0) {
    die "Usage: $PROGRAM_NAME <php.ini file to patch>\n";
}

#
# Load the current php.ini file into memory. Then create a backup.
#

my $php_ini_file = $ARGV[0];
my @php_ini_lines;

if (open my $fh, '<', $php_ini_file) {
    @php_ini_lines = <$fh>;
    close $fh;
}
else {
    die "Error: $PROGRAM_NAME: Unable to open: $php_ini_file\n";
}

my $current_datetime = strftime('%Y%m%d%H%M%S', localtime);
my $cp_ok = system 'cp', '-p', $php_ini_file, $php_ini_file . ".$current_datetime";

if ($cp_ok != 0) {
    die "Error: $PROGRAM_NAME: Unable to create backup of: $php_ini_file\n";
}

#
# Write the new php.ini file.
# Include commented out versions of any lines that are modified.
#

my $patched_post_max_size       = 0;
my $patched_upload_max_filesize = 0;

if (open my $fh, '>', $php_ini_file) {
    foreach my $line (@php_ini_lines) {
        if ($line =~ m/^\s*post_max_size\s*=/sxm) {
            print {$fh} '; ' . $line;
            print {$fh} "post_max_size = 800M\n";
            $patched_post_max_size = 1;
        }
        elsif ($line =~ m/^\s*upload_max_filesize\s*=/sxm) {
            print {$fh} '; ' . $line;
            print {$fh} "upload_max_filesize = 800M\n";
            $patched_upload_max_filesize = 1;
        }
        else {
            print {$fh} $line;
        }
    }
    if (!$patched_post_max_size || !$patched_upload_max_filesize) {
        print {$fh} "\n\n; Configuration added by the SWAMP installer\n";
    }
    if (!$patched_post_max_size) {
        print {$fh} "post_max_size = 800M\n";
    }
    if (!$patched_upload_max_filesize) {
        print {$fh} "upload_max_filesize = 800M\n";
    }
    close $fh;
}
else {
    die "Error: $PROGRAM_NAME: Unable to write: $php_ini_file\n";
}

exit 0;
