#!/usr/bin/env perl
use strict;
use warnings;
use POSIX qw(strftime);

#
# Check for required command-line arguments.
#

if (scalar(@ARGV) <= 0) {
    print "Error: php.ini file to patch must be specified on the command line.\n";
    exit 1;
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
    print "Error: Unable to open $php_ini_file.\n";
    exit 1;
}

my $current_datetime = strftime('%Y%m%d%H%M%S', localtime);
my $cp_ok = system 'cp', '-p', $php_ini_file, $php_ini_file . ".$current_datetime";

if ($cp_ok != 0) {
    print "Error: Unable to create a backup copy of $php_ini_file.\n";
    exit 1;
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
    print "Error: Unable to write to $php_ini_file.\n";
    exit 1;
}

exit 0;
