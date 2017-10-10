#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

#
# Build the swampinabox-{version}-tools.tar.gz bundle for SWAMP-in-a-Box.
#

#
# For 'perlcritic'.
#
## no critic (RequireDotMatchAnything, RequireLineBoundaryMatching, RequireExtendedFormatting)

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
    my ($cmd)  = @_;
    my $output = qx($cmd 2>&1);    # capture both standard out and standard error
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
    while ($object) {
        if (-f $object) {
            unlink $object || print "Error: Failed to remove file: $object\n";
        }
        elsif (-d $object) {
            rmdir $object || print "Error: Failed to remove directory: $object\n";
        }
        elsif (-e $object) {
            print "Error: Not sure how to remove: $object\n";
        }
        $object = pop @temp_objects;
    }
    if (scalar @temp_objects > 0) {
        print "Error: Failed to remove all temporary objects\n";
    }
    return;
}

#
# Perform all necessary cleanup tasks (e.g., before exiting).
#
sub do_cleanup {
    remove_temp_objects();
    return;
}

#
# Make sure cleanup tasks happen even on common signals.
#
local $SIG{INT}  = sub { do_cleanup(); toggle_terminal_echo(1); exit 1; };
local $SIG{TERM} = sub { do_cleanup(); toggle_terminal_echo(1); exit 1; };

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

sub show_usage_and_exit {    ## no critic (RequireFinalReturn)
    my $usage_message = <<"EOF";
Usage: $PROGRAM_NAME [options]

Build the swampinabox-{version}-tools.tar.gz bundle for SWAMP-in-a-Box.

Options:

  --inventory   Inventory file containing a list of tool archive files
  --scripts     Directory containing the database scripts for each listed tool
  --version     The SWAMP-in-a-Box release for which to name the bundle
  --build       The build number to use for the bundle
  --output-dir  The directory to place the final output in

  --help, -?  Display this message
EOF

    print $usage_message;
    exit_abnormally();
}

############################################################################

sub get_options {
    my @errors  = ();
    my %options = ();

    my %defaults = (
        # Root directory that will be populated and turned into the bundle
        'working-dir' => 'swampinabox-tools',
    );

    my $ok = Getopt::Long::GetOptions(\%options,
                'help|?',
                'inventory-file=s@',
                'scripts-dir=s@',
                'version=s',
                'build=s',
                'output-dir=s',
                );

    while (my ($key, $value) = each %defaults) {
        if (!exists $options{$key}) {
            $options{$key} = $value;
        }
    }

    if ($ok && $options{'help'}) {
        show_usage_and_exit();
    }

    if (!$options{'inventory-file'} && !$options{'scripts-dir'}) {
        push @errors, 'Required option missing (provide at least one): inventory scripts';
    }

    if ($options{'inventory-file'}) {
        my @inventory_files = @{$options{'inventory-file'}};
        for my $file (@inventory_files) {
            if (!-r $file) {
                push @errors, "Not a readable file: $file";
            }
        }
    }

    if ($options{'scripts-dir'}) {
        my @scripts_dirs = @{$options{'scripts-dir'}};
        for my $dir (@scripts_dirs) {
            if (!-d $dir) {
                push @errors, "Not a directory: $dir";
            }
        }
    }

    my $version = $options{'version'};
    if (!$version) {
        push @errors, 'Required option missing: version';
    }

    my $build = $options{'build'};
    if (!$build) {
        push @errors, 'Required option missing: build';
    }

    my $output_dir = $options{'output-dir'};
    if (!$output_dir) {
        push @errors, 'Required option missing: output-dir';
    }

    my $working_dir = $options{'working-dir'};
    if (-e $working_dir) {
        push @errors, "Already exists: $working_dir";
    }

    for my $msg (@errors) {
        print $msg . "\n";
    }

    if (!$ok || scalar @errors > 0) {
        print "\n";
        show_usage_and_exit();
    }

    return \%options;
}

############################################################################

sub check_system_requirements {
    my ($options) = @_;

    my @inventory_files = $options->{'inventory-file'} ? @{$options->{'inventory-file'}} : ();
    my @scripts_dirs    = $options->{'scripts-dir'}    ? @{$options->{'scripts-dir'}}    : ();
    my @errors          = ();
    my @tools           = ();

    for my $inventory_file (@inventory_files) {
        open my $fh, '<', $inventory_file
          || exit_abnormally("Unable to open: $inventory_file");
        my @inventory_lines = <$fh>;
        close $fh;

        for my $line (@inventory_lines) {
            $line = trim($line);
            push @tools, "/swampcs/releases/$line";
        }
    }

    for my $dir (@scripts_dirs) {
        for my $script (glob "'${dir}/*.sql'") {

            open my $fh, '<', $script
              || exit_abnormally("Unable to open: $script");
            my @script_lines = <$fh>;
            close $fh;

            for my $line (@script_lines) {
                if ($line =~ /^.*tool_path\s*=\s*['"](.*)['"].*$/m) {
                    push @tools, $1;
                }
            }
        }
    }

    for my $tool_path (@tools) {
        if (!-r $tool_path) {
            push @errors, "No such tool archive file (or file is not readable): $tool_path";
        }
    }

    $options->{'tools'} = \@tools;

    for my $msg (@errors) {
        print $msg . "\n";
    }

    if (scalar @errors > 0) {
        exit_abnormally('Unable to read all required files');
    }
    return;
}

############################################################################

sub create_working_dir {
    my ($options) = @_;
    my $working_dir = $options->{'working-dir'};

    print "Creating: $working_dir\n";

    push @temp_objects, $working_dir;
    mkdir $working_dir || exit_abnormally("Failed to create: $working_dir");
    return;
}

sub populate_working_dir {
    my ($options) = @_;

    my @tools        = @{$options->{'tools'}};
    my $version      = $options->{'version'};
    my $build        = $options->{'build'};
    my $working_dir  = $options->{'working-dir'};
    my $version_file = "$working_dir/version.txt";

    print "Creating: $version_file\n";

    push @temp_objects, $version_file;
    open my $fh, '>', $version_file
      || exit_abnormally("Error: Unable to open: $version_file");
    print {$fh} "release = $version\n";
    print {$fh} "buildnumber = $build\n";
    close $fh;

    for my $tool (@tools) {
        my $tool_basename = basename($tool);
        my $from          = "$tool";
        my $to            = "$working_dir/$tool_basename";

        print "Copying: '$from' to '$to'\n";

        push @temp_objects, $to;
        copy($from, $to) || exit_abnormally("Failed to copy '$from' to '$to'");
    }
    return;
}

sub create_tools_bundle {
    my ($options) = @_;

    my $version      = $options->{'version'};
    my $output_dir   = $options->{'output-dir'};
    my $working_dir  = $options->{'working-dir'};
    my $tools_bundle = "swampinabox-${version}-tools.tar.gz";
    my $output_path  = "$output_dir/$tools_bundle";

    my $escaped_working_dir = escape_dquotes($working_dir);
    my $escaped_output_path = escape_dquotes($output_path);

    if (-f $tools_bundle) {
        if (!unlink $tools_bundle) {
            exit_abnormally("Failed to remove existing tools bundle: '$tools_bundle'");
        }
    }

    print "Creating: '$output_path' from '$working_dir'\n";

    my ($output, $status) = do_command(qq(tar -czv -f "$escaped_output_path" "$escaped_working_dir"));
    if ($status) {
        exit_abnormally("Failed to create: $output_path", $output);
    }

    $options->{'tools-bundle'} = $output_path;
    return;
}

############################################################################

sub main {
    my $options = get_options();

    check_system_requirements($options);
    create_working_dir($options);
    populate_working_dir($options);
    create_tools_bundle($options);

    my $tools_bundle = $options->{'tools-bundle'};
    print "Successfully created tools bundle: $tools_bundle\n";
    return;
}

main();
exit_normally();
