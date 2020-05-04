#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

#
# Build an archive containing the files listed in one or more inventory files.
#

use utf8;
use strict;
use warnings;

use English qw( -no_match_vars );
use File::Basename qw(basename);
use File::Copy qw(copy);
use File::Spec::Functions qw(catfile);
use Getopt::Long;

use FindBin;
use lib "$FindBin::Bin/../../runtime/perl5";
use SWAMP::SiB_Utilities qw(:all);

#
# Store command-line options and data derived from them.
#
my %options = ();

#
# Track temporary files and directories created by this script.
#
my @temp_objects = ();

############################################################################

#
# Perform all necessary cleanup tasks (e.g., before exiting).
#
sub do_cleanup {
    remove_temp_objects(\@temp_objects);
    return;
}

#
# Make sure cleanup tasks happen even on common signals.
#
local $SIG{INT}  = sub { do_cleanup(); exit 1; };
local $SIG{TERM} = sub { do_cleanup(); exit 1; };

############################################################################

sub exit_normally {
    do_cleanup();
    exit 0;
}

sub exit_abnormally {
    my ($message, $details) = @_;
    $message = trim($message);
    $details = trim($details);

    if (defined $message) {
        print "Error: $message";
        print " ($details)" if defined $details;
        print "\n";
    }
    do_cleanup();
    exit 1;
}

sub show_usage_and_exit {    ## no critic (RequireFinalReturn)
    my $usage_message = <<"EOF";
Usage: $PROGRAM_NAME [required arguments] [options]

Build an archive containing the files listed in one or more inventory files.

Required arguments:
  --inventory <file>    SWAMP inventory file (can be specified multiple times)
  --output-file <file>  The archive file to create
  --root-dir <str>      The name of the archive's root directory
  --version <str>       The version number to embed in the archive
  --build <str>         The build number to embed in the archive

Options:
  --help, -?            Display this message
EOF

    print $usage_message;
    exit_abnormally();
}

############################################################################

sub process_cmd_line_args {
    my @errors = ();
    my $ok =
      Getopt::Long::GetOptions(\%options,
        'inventory=s@', 'output-file=s', 'root-dir=s', 'version=s', 'build=s',
        'help|?');

    if ($ok && $options{'help'}) {
        show_usage_and_exit();
    }

    if (!defined $options{'inventory'}) {
        push @errors, 'Required argument is missing: inventory';
    }
    else {
        for my $file (@{$options{'inventory'}}) {
            if (!-f $file) {
                push @errors, "Not a file: $file";
            }
            elsif (!(basename($file) =~ /^(platform|tool)/)) {
                push @errors, "Not a recognized inventory file: $file";
            }
        }
    }

    my $output_file = $options{'output-file'};
    if (!defined $output_file) {
        push @errors, 'Required argument is missing: output-file';
    }
    elsif (-e $output_file) {
        push @errors, "Already exists: $output_file";
    }

    my $root_dir = $options{'root-dir'};
    if (!defined $root_dir) {
        push @errors, 'Required argument is missing: root-dir';
    }
    elsif (-e $root_dir) {
        push @errors, "Already exists: $root_dir";
    }

    if (!defined $options{'version'}) {
        push @errors, 'Required argument is missing: version';
    }

    if (!defined $options{'build'}) {
        push @errors, 'Required argument is missing: build';
    }

    for my $msg (@errors) {
        print $msg . "\n";
    }

    if (!$ok || scalar @errors > 0) {
        print "\n";
        show_usage_and_exit();
    }
    return;
}

############################################################################

sub check_requirements {
    my @errors          = ();
    my @files           = ();
    my @inventory_files = @{$options{'inventory'}};

    for my $inventory_file (@inventory_files) {
        my @inventory_lines = split /^/, read_file($inventory_file);
        for my $line (@inventory_lines) {
            $line = trim($line);
            if ($line ne q()) {
                my $inventory_file_basename = basename($inventory_file);
                if ($inventory_file_basename =~ /^tool/) {
                    push @files,
                      catfile('/swampcs', 'releases', $line);
                }
                elsif ($inventory_file_basename =~ /^platform/) {
                    push @files,
                      catfile('/swampcs', 'platforms', 'images', $line);
                }
            }
        }
    }
    $options{'files'} = \@files;

    for my $file (@files) {
        if (!-r $file) {
            push @errors, "File is not readable: $file";
        }
    }

    for my $msg (@errors) {
        print $msg . "\n";
    }

    if (scalar @errors > 0) {
        exit_abnormally('Failed to read all required files');
    }
    return;
}

############################################################################

sub create_archive_dir {
    my $root_dir = $options{'root-dir'};

    print "Creating $root_dir\n";

    push @temp_objects, $root_dir;
    mkdir($root_dir)
      || exit_abnormally("Failed to create: $root_dir");
    chmod(0755, $root_dir)    ## no critic (ProhibitMagicNumbers)
      || exit_abnormally("Failed to set permissions on: $root_dir");
    return;
}

sub populate_archive_dir {
    my @files        = @{$options{'files'}};
    my $version      = $options{'version'};
    my $build        = $options{'build'};
    my $root_dir     = $options{'root-dir'};
    my $version_file = catfile($root_dir, 'version.txt');

    print "Creating $version_file\n";

    push @temp_objects, $version_file;
    write_file($version_file, "version = $version\nbuild = $build\n");
    chmod(0644, $version_file)    ## no critic (ProhibitMagicNumbers)
      || exit_abnormally("Failed to set permissions on: $version_file");

    for my $file (@files) {
        my $file_basename = basename($file);
        my $from          = $file;
        my $to            = catfile($root_dir, $file_basename);

        print "Copying $from\n";

        push @temp_objects, $to;
        copy($from, $to)
          || exit_abnormally("Failed to copy '$from' to '$to'");
        chmod(0644, $to)    ## no critic (ProhibitMagicNumbers)
          || exit_abnormally("Failed to set permissions on: $to");
    }
    return;
}

sub create_archive {
    my $root_dir        = $options{'root-dir'};
    my $output_file     = $options{'output-file'};
    my $root_dir_arg    = make_shell_arg($root_dir);
    my $output_file_arg = make_shell_arg($output_file);

    print "Creating $output_file\n";

    my ($output, $error) =
      do_command("tar -cz -f $output_file_arg $root_dir_arg");
    if ($error) {
        exit_abnormally("Failed to create: $output_file", $output);
    }
    return;
}

############################################################################

sub main {
    print "\n### Building Archive\n\n";

    process_cmd_line_args();
    check_requirements();

    create_archive_dir();
    populate_archive_dir();
    create_archive();

    print "Finished building archive\n";
    return;
}

main();
exit_normally();
