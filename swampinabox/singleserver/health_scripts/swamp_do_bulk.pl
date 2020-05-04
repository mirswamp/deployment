#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

#
# Perform bulk actions on a SWAMP instance.
#

#
# For 'perlcritic'.
#
## no critic (MagicNumbers)

use utf8;
use strict;
use warnings;

use English qw( -no_match_vars );
use File::Spec::Functions qw(catfile);
use Getopt::Long;
use POSIX qw(:sys_wait_h);

############################################################################

#
# Copy these functions in from 'SiB_Utilities.pm', so that this script can
# be distributed without having to include additional libraries.
#

#
# Run the given command, and return all its output and its status code.
#
sub do_command {
    my ($cmd)  = @_;
    my $output = qx($cmd 2>&1);
    my $error  = $CHILD_ERROR;
    return ($output, $error);
}

#
# Return the given string with leading and trailing whitespace removed.
#
sub trim {
    my ($val) = @_;
    if (defined $val) {
        $val =~ s/^\s+|\s+$//g;
    }
    return $val;
}

#
# Return the given string single-quoted for the shell.
#
sub make_shell_arg {
    my ($val) = @_;
    if (defined $val) {
        $val =~ s/'/'\\''/g;
        $val = qq('$val');
    }
    return $val;
}

#
# Return the contents of the given file (path) as a string.
#
sub read_file {
    my ($path) = @_;
    local $INPUT_RECORD_SEPARATOR = undef;
    open(my $fh, '<', $path) || die "Error: Failed to open: $path\n";
    my $contents = <$fh>;
    close($fh) || die "Error: Failed to close: $path\n";
    return $contents;
}

############################################################################

#
# Write out a "title", of sorts, to separate sections of output.
#
sub print_title {
    my ($title) = @_;
    print "\n### $title\n\n";
    return;
}

#
# Perform all necessary cleanup tasks (e.g., before exiting).
#
sub do_cleanup {
    my $error_count = 0;
    my $child_pid = waitpid -1, WNOHANG;
    while ($child_pid != -1) {
        if ($child_pid == 0) {
            sleep 1;    # wait 1 second if nothing is ready
        }
        elsif ($CHILD_ERROR) {
            $error_count += 1;
        }
        $child_pid = waitpid -1, WNOHANG;
    }
    if ($error_count > 0) {
        exit_abnormally("$error_count worker(s) exited with an error");
    }
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

Perform bulk actions on a SWAMP instance.

Required arguments:
  --jar <file>         SWAMP Java CLI '.jar' file
  --mode <str>         Mode to run in: upload (default: upload)

Options for 'upload' mode:
  --project <id>       SWAMP project to add packages to (must already exist)
  --pkg-repo <dir>     Directory containing packages (default: '.')
  --num-workers <num>  Number of workers/simultaneous uploads (default: 1)
  --num-pkgs <num>     Number of packages to upload per worker (default: 1)
  --all-pkgs           Ignore '--num-pkgs' and instead upload all packages

Other options:
  --help, -?           Display this message
EOF

    print $usage_message;
    exit_abnormally();
}

############################################################################

sub get_options {
    my @errors   = ();
    my %options  = ();
    my %defaults = (
        'mode'         => 'upload',
        'num-pkgs'     => 1,
        'num-workers'  => 1,
        'pkg-repo-dir' => q(.),
    );

    Getopt::Long::Configure('bundling_override');

    my $ok = Getopt::Long::GetOptions(
        \%options,
        'help|?',
        'jar-file|jar=s',
        'mode=s',
        'project-id|project=s',
        'pkg-repo-dir|pkg-repo=s',
        'num-workers=i',
        'num-pkgs=i',
        'all-pkgs',
    );

    while (my ($key, $value) = each %defaults) {
        if (!exists $options{$key}) {
            $options{$key} = $value;
        }
    }

    if (!$ok || $options{'help'}) {
        print "\n" if !$ok;
        show_usage_and_exit();
    }

    my $jar_file = $options{'jar-file'};
    if (!defined $jar_file) {
        push @errors, 'Required argument missing: jar';
    }
    elsif (!-f $jar_file) {
        push @errors, "Not a file: $jar_file";
    }

    my $mode = $options{'mode'};
    if (!defined $mode) {
        push @errors, 'Required argument missing: mode';
    }
    elsif ($mode eq 'upload') {
        if (!defined $options{'project-id'}) {
            push @errors, 'Required option missing: project';
        }

        my $pkg_repo_dir = $options{'pkg-repo-dir'};
        if (!defined $pkg_repo_dir) {
            push @errors, 'Required option missing: pkg-repo';
        }
        elsif (!-d $pkg_repo_dir) {
            push @errors, "Not a directory: $pkg_repo_dir";
        }

        my $num_workers = $options{'num-workers'};
        if (!defined $num_workers) {
            push @errors, 'Required option missing: num-workers';
        }
        elsif ($num_workers < 1) {
            push @errors, "Worker count must be 1 or greater: $num_workers";
        }

        my $num_pkgs = $options{'num-pkgs'};
        my $all_pkgs = $options{'all-pkgs'};
        if (!defined $num_pkgs && !defined $all_pkgs) {
            push @errors, 'Must specify one of: num-pkgs all-pkgs';
        }
        elsif (!defined $all_pkgs && defined $num_pkgs && $num_pkgs < 1) {
            push @errors, "Package count must be 1 or greater: $num_pkgs";
        }
    }
    else {
        push @errors, "Not a recognized mode: $mode";
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

#
# Invoke the SWAMP Java CLI with the given arguments.
#
sub do_cli {    ## no critic (RequireArgUnpacking)
    my $options         = shift @_;
    my $jar_file        = $options->{'jar-file'};
    my @command_pieces  = ();
    my $command_string  = q();
    my $tries_remaining = 2;

    #
    # Build the command line.
    #
    push @command_pieces, 'java', '-jar', make_shell_arg($jar_file);
    push @command_pieces, map { make_shell_arg($_) } @_;
    $command_string = join q( ), @command_pieces;

    #
    # Try the command a few times before giving up.
    #
    my ($output, $error) = do_command($command_string);
    while ($error && $tries_remaining > 0) {
        $tries_remaining -= 1;
        ($output, $error) = do_command($command_string);
    }
    if ($error) {
        exit_abnormally(
            'The SWAMP Java CLI returned an error',
            "$command_string: $output",
        );
    }
    return $output;
}

#
# Check that the SWAMP Java CLI has a valid user session.
#
sub check_session {
    my ($options) = @_;

    print_title('Session');
    print do_cli($options, 'user', '--info');
    return;
}

#
# Check that the SWAMP Java CLI has a valid project to work with.
#
sub check_project {
    my ($options) = @_;
    my $project_id = $options->{'project-id'};

    print_title('Project');
    print "ID: $project_id\n";
    print 'UUID: ';
    print do_cli($options, 'projects', '--name', $project_id, '--uuid');
    return;
}

#
# Check that the SWAMP Java CLI has valid platforms to work with.
#
sub check_platforms {
    my ($options) = @_;

    print_title('Platforms');

    my $platforms_list = do_cli($options, 'platforms', '--list', '--quiet');
    chomp $platforms_list;

    my %platforms = map { $_ => q() } split /\n/, $platforms_list;
    $options->{'platforms'} = \%platforms;

    print $platforms_list . "\n";
    return;
}

############################################################################

#
# Spawn off child processes that upload packages to the SWAMP.
#
sub bulk_upload_packages {
    my ($options)        = @_;
    my $num_workers      = $options->{'num-workers'};
    my $pkg_repo_dir     = $options->{'pkg-repo-dir'};
    my $pkg_repo_dir_arg = make_shell_arg($pkg_repo_dir);

    print_title('Uploading Packages');

    #
    # Locate all directories that look like they contain a package.
    #
    my ($listing, $error) = do_command(qq(find $pkg_repo_dir_arg -name package.conf -exec dirname '--' '{}' ';'));
    chomp $listing;

    if ($error) {
        exit_abnormally('Failed to find directories with packages', $listing);
    }

    my @pkg_dirs = split /\n/, $listing;
    $options->{'pkg-dirs'} = \@pkg_dirs;

    if (scalar @pkg_dirs < 1) {
        exit_abnormally('Failed to find directories with packages');
    }

    #
    # Spawn worker processes to do the actual work of uploading the packages.
    #
    for (1 .. $num_workers) {
        my $pid = fork;
        if ($pid) {
            print "Forked a new child process: PID: $pid\n";
        }
        elsif (defined $pid) {
            do_package_upload_loop($options);
            exit_normally();
        }
        else {
            # TODO baydemir: Handle errors from 'fork'
        }
    }
    return;
}

#
# Upload multiple packages to the SWAMP.
#
sub do_package_upload_loop {
    my ($options) = @_;
    my $all_pkgs  = $options->{'all-pkgs'};
    my $num_pkgs  = $options->{'num-pkgs'};
    my @pkg_dirs  = @{$options->{'pkg-dirs'}};
    my $num_dirs  = scalar @pkg_dirs;

    if ($all_pkgs) {
        for my $pkg_dir (@pkg_dirs) {
            do_package_upload($options, $pkg_dir);
        }
    }
    else {
        for (1 .. $num_pkgs) {
            my $pkg_dir = $pkg_dirs[ int rand $num_dirs ];
            do_package_upload($options, $pkg_dir);
        }
    }
    return;
}

#
# Upload a single package to the SWAMP.
#
sub do_package_upload {
    my ($options, $pkg_dir) = @_;
    my $platforms  = $options->{'platforms'};
    my $project_id = $options->{'project-id'};

    my $conf_path      = catfile($pkg_dir, 'package.conf');
    my $conf           = (-r $conf_path) ? read_file($conf_path) : q();
    my ($archive_file) = ($conf =~ /^\s*package-archive\s*=\s*(.*)$/m);
    my $archive_path   = catfile($pkg_dir, trim($archive_file));

    my $os_deps_path   = catfile($pkg_dir, 'pkg-os-dependencies.conf');
    my $os_deps        = (-r $os_deps_path) ? read_file($os_deps_path) : q();
    my @os_deps_pieces = split /\n/, $os_deps;

    my @command = ();
    push @command, 'packages', '--upload', '--quiet';
    push @command, '--project', $project_id;
    push @command, '--pkg-archive', $archive_path;
    push @command, '--pkg-conf', $conf_path;

    for my $os_dep (@os_deps_pieces) {
        my ($platform) = ($os_dep =~ /^\s*dependencies-([^=]*)=.*$/);
        if (exists $platforms->{trim($platform)}) {
            $os_dep =~ s/^\s*dependencies-//;
            push @command, '--os-deps', $os_dep;
        }
    }

    my $pkg_version_uuid = do_cli($options, @command);
    print "Package version UUID: $pkg_version_uuid";
    return;
}

############################################################################

sub main {
    my $options = get_options();
    my $mode    = $options->{'mode'};

    check_session($options);
    check_project($options);
    check_platforms($options);

    if ($mode eq 'upload') {
        bulk_upload_packages($options);
    }
    return;
}

main();
exit_normally();
