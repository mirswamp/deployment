#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

#
# Build the swampinabox-{version}-tools.tar.gz bundle for SWAMP-in-a-Box.
#

use utf8;
use strict;
use warnings;

use English qw( -no_match_vars );
use File::Basename;
use File::Copy;
use Getopt::Long;

#
# Track temporary files and directories created by this script.
#
my @temp_objects = ();

############################################################################

#
# Execute the given command, and return all its output and its status code.
#
sub do_command {
    my ($cmd) = @_;

    my $output = qx{$cmd 2>&1};  # capture both standard out and standard error
    my $status = $CHILD_ERROR;

    return ($output, $status);
}

#
# Return the given string without leading and trailing whitespace.
#
sub trim {
    my ($val) = @_;
    if ($val) {
        $val =~ s/^\s+|\s+$//gm;
    }
    return $val;
}

#
# Backslash escape all double quotes in the given string.
#
sub escape_dquotes {
    my ($val) = @_;
    if ($val) {
        $val =~ s/"/\\"/g;
    }
    return $val;
}

############################################################################

#
# Remove temporary files and directories.
#
sub remove_temp_objects {
    my $object = pop @temp_objects;
    while ( $object ) {
        if ( -f $object ) {
            unlink $object || print "ERROR: Failed to remove file: '$object'\n";
        }
        elsif ( -d $object ) {
            rmdir $object || print "ERROR: Failed to remove directory: '$object'\n";
        }
        else {
            print "ERROR: Not sure how to remove: '$object'\n";
        }
        $object = pop @temp_objects;
    }
    if ( scalar @temp_objects > 0 ) {
        print "ERROR: Failed to process all temporary objects\n";
    }
}

#
# Perform all necessary cleanup tasks (e.g., before exiting).
#
sub do_cleanup {
    remove_temp_objects();
}

############################################################################

sub exit_normally {
    do_cleanup();
    exit 0;
}

sub exit_abnormally {
    my ($message, $details) = @_;

    $message = trim($message);
    $details = trim($details);

    if ($message) {
        print "Error: $message" . ($details ? " ($details)" : q()) . "\n";
    }

    do_cleanup();
    exit 1;
}

sub show_usage_and_exit {
    my $usage_message = <<"EOF";
Usage: $PROGRAM_NAME [options]

Build the swampinabox-{version}-tools.tar.gz bundle for SWAMP-in-a-Box.

Options:

  --scripts   Directory containing the database scripts for each listed tool
  --tools     File containing the list of tool archives to include, one per line
  --version   The SWAMP-in-a-Box release for which to name the bundle

  --help, -?  Display this message

EOF

    print $usage_message;
    exit_abnormally();
}

############################################################################

sub get_options {
    my @errors = ();
    my %options = ();

    my %defaults = (
        # Root directory that will be populated and turned into the bundle
        'working-dir' => 'swampinabox-tools',

        # Where to find the individual tool archives
        'tool-install-dir' => '/swamp/store/SCATools',
        );

    my $ok = Getopt::Long::GetOptions(\%options,
                'help|?',
                'tools-file=s',
                'scripts-dir=s@',
                'version=s',
                );

    while (my ($key, $value) = each %defaults) {
        if (! exists $options{$key}) {
            $options{$key} = $value;
        }
    }

    if ($ok && $options{'help'}) {
        show_usage_and_exit();
    }

    my @scripts_dirs = @{$options{'scripts-dir'}};
    if ( scalar @scripts_dirs < 1 ) {
        push @errors, 'Required option missing: scripts';
    }
    else {
        for my $dir (@scripts_dirs) {
            if ( ! -d $dir ) {
                push @errors, "Not a directory: '$dir'";
            }
        }
    }

    my $tools_file = $options{'tools-file'};
    if ( ! defined $tools_file ) {
        push @errors, 'Required option missing: tools';
    }
    elsif ( ! -f $tools_file ) {
        push @errors, "Unable to read tools file: '$tools_file'";
    }

    my $version = $options{'version'};
    if ( ! defined $version ) {
        push @errors, 'Required option missing: version';
    }

    my $working_dir = $options{'working-dir'};
    if ( -e $working_dir ) {
        push @errors, "'$working_dir' already exists";
    }

    for my $key (qw()) {
        my $val = $options{$key};
        if (! defined $val || ! -f $val) {
            push @errors, "Missing file from SWAMP installation: $val";
        }
    }

    for my $key (qw(tool-install-dir)) {
        my $val = $options{$key};
        if (! defined $val || ! -d $val) {
            push @errors, "Missing directory from SWAMP installation: $val";
        }
    }

    for my $msg (@errors) {
        print $msg . "\n";
    }

    if (! $ok || scalar @errors > 0) {
        print "\n";
        show_usage_and_exit();
    }

    return \%options;
}

############################################################################

sub check_system_requirements {
    my ($options) = @_;

    my @scripts_dirs      = @{$options->{'scripts-dir'}};
    my $tools_file        = $options->{'tools-file'};
    my $tool_install_dir  = $options->{'tool-install-dir'};
    my @errors            = ();
    my @tools             = ();

    open my $fh, '<', $tools_file || exit_abnormally("Failed to open '$tools_file' for reading");
    while (my $tool = <$fh>) {
        chomp $tool;
        next if ! $tool;
        push @tools, $tool;
    }
    close $fh || exit_abnormally("Failed to close '$tools_file'");

    $options->{'tools'} = \@tools;

    for my $tool (@tools) {
        if ( ! -r "${tool_install_dir}/${tool}" ) {
            push @errors, "Unable to read tool archive: '$tool'";
        }

        my $tool_basename = $tool;
        $tool_basename =~ s/\.gz$//;
        $tool_basename =~ s/\.tar$//;

        my @scripts = ();
        for my $dir (@scripts_dirs) {
            push @scripts, glob "'${dir}/${tool_basename}.sql'";
        }
        if (scalar @scripts < 1) {
            push @errors, "Unable to read tool database script for: '$tool_basename'";
        }
    }

    for my $dir (@scripts_dirs) {
        for my $script (glob "'${dir}/*.sql'") {
            my $script_basename = basename($script);
            $script_basename =~ s/\.sql$//;

            if ( ! -r "${tool_install_dir}/${script_basename}.tar" && ! -r "${tool_install_dir}/${script_basename}.tar.gz" ) {
                push @errors, "Unable to find tool archive for database script: '$script'";
            }
        }
    }

    for my $msg (@errors) {
        print $msg . "\n";
    }

    if (scalar @errors > 0) {
        exit_abnormally('Unable to read all required files');
    }
}

############################################################################

sub create_working_dir {
    my ($options) = @_;
    my $working_dir = $options->{'working-dir'};

    print "Creating '$working_dir'\n";

    mkdir $working_dir || exit_abnormally("Failed to create '$working_dir'");
    push @temp_objects, $working_dir;
}

sub populate_working_dir {
    my ($options) = @_;

    my @tools             = @{$options->{'tools'}};
    my $tool_install_dir  = $options->{'tool-install-dir'};
    my $working_dir       = $options->{'working-dir'};

    for my $tool (@tools) {
        my $from  = "${tool_install_dir}/${tool}";
        my $to    = "${working_dir}/${tool}";

        print "Copying '$from' to '$to'\n";

        copy($from, $to) || exit_abnormally("Failed to copy '$from' to '$to'");
        push @temp_objects, $to;
    }
}

sub create_tools_bundle {
    my ($options) = @_;

    my $version       = $options->{'version'};
    my $working_dir   = $options->{'working-dir'};
    my $tools_bundle  = "swampinabox-${version}-tools.tar.gz";

    my $escaped_working_dir   = escape_dquotes($working_dir);
    my $escaped_tools_bundle  = escape_dquotes($tools_bundle);

    if ( -f $tools_bundle ) {
        if ( ! unlink $tools_bundle ) {
            exit_abnormally("Failed to remove existing tools bundle: '$tools_bundle'");
        }
    }

    print "Creating '$tools_bundle' from '$working_dir'\n";

    my ($output, $status) = do_command(qq(tar -czv -f "$escaped_tools_bundle" "$escaped_working_dir"));
    if ($status) {
        exit_abnormally("Failed to create '$tools_bundle'", $output);
    }

    $options->{'tools-bundle'} = $tools_bundle;
}

############################################################################

sub main {
    my $options = get_options();

    check_system_requirements($options);
    create_working_dir($options);
    populate_working_dir($options);
    create_tools_bundle($options);

    my $tools_bundle = $options->{'tools-bundle'};
    print "Successfully created tools bundle: '$tools_bundle'\n";
}

main();
exit_normally();
