#!/usr/bin/env perl

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

#
# Patch ssl.conf for SWAMP-in-a-Box.
# Specifically, attempt to enforce the SSL protocols and ciphers used.
#

#
# For 'perlcritic'.
#
## no critic (RequireDotMatchAnything, RequireLineBoundaryMatching, RequireExtendedFormatting)

use utf8;
use strict;
use warnings;

use English qw( -no_match_vars );
use POSIX qw(strftime);

#
# Taken from the guide at bettercrypto.org.
#
my $desired_protocol_directive = 'SSLProtocol all -SSLv2 -SSLv3';
my $desired_ciphers_directive  = 'SSLCipherSuite EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA256:EECDH:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!IDEA:!ECDSA:kEDH:CAMELLIA128-SHA:AES128-SHA';

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
        $val =~ s/^\s+|\s+$//g;
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

#
# Create a backup copy of the given file.
#
sub backup_file {
    my ($filename) = @_;
    my $current_datetime = strftime('%Y%m%d%H%M%S', localtime);
    my $old_filename     = escape_dquotes(qq($filename));
    my $new_filename     = escape_dquotes(qq($filename.$current_datetime));
    my ($output, $status) = do_command(qq(cp -p "$old_filename" "$new_filename"));
    if ($status) {
        exit_abnormally("Failed to create backup copy of: $filename", $output);
    }
    return;
}

############################################################################

sub exit_normally {
    exit 0;
}

sub exit_abnormally {
    my ($message, $details) = @_;
    $message = trim($message);
    $details = trim($details);

    if ($message) {
        print "Error: $message" . ($details ? " ($details)" : q()) . "\n";
    }
    exit 1;
}

############################################################################

#
# Check for required command-line arguments.
#
if (scalar(@ARGV) <= 0) {
    die "Usage: $PROGRAM_NAME <ssl.conf file to patch>\n";
}

#
# Load the current ssl.conf file into memory.
#
my $ssl_conf_file = $ARGV[0];
my @ssl_conf_lines;

open(my $fh, '<', $ssl_conf_file)
  || die "Error: Unable to read: $ssl_conf_file\n";
@ssl_conf_lines = <$fh>;
close $fh;

#
# Scan for lines that need to be modified.
#
print "Determining whether $ssl_conf_file needs to be patched\n";

my @new_ssl_conf_lines;
my $made_edits = 0;

while (defined(my $line = shift @ssl_conf_lines)) {
    my $trimmed_line = trim($line);

    if ($line =~ m/^(\s*)(SSLProtocol\s+all\s+-SSLv2\s*)$/i && $line ne "$1$desired_protocol_directive\n") {
        push @new_ssl_conf_lines, "$1# $2";
        push @new_ssl_conf_lines, "$1$desired_protocol_directive\n";
        $made_edits = 1;
        print "Found: $trimmed_line\n";
    }
    elsif ($line =~ m/^(\s*)(SSLCipherSuite[^\\]*)$/i && $line ne "$1$desired_ciphers_directive\n") {
        push @new_ssl_conf_lines, "$1# $2";
        push @new_ssl_conf_lines, "$1$desired_ciphers_directive\n";
        push @new_ssl_conf_lines, "$1SSLHonorCipherOrder On\n";
        $made_edits = 1;
        print "Found: $trimmed_line\n";
    }
    elsif ($line =~ m/^(\s*)(SSLCipherSuite.*[\\].*)$/i && $line ne "$1$desired_ciphers_directive\n") {
        print "Note: Found multi-line SSLCipherSuite directive - not modifying\n";
    }
    elsif ($line =~ m/^(\s*)(SSLCompression\s+on\s*)$/i) {
        push @new_ssl_conf_lines, "$1# $2";
        push @new_ssl_conf_lines, "$1SSLCompression off\n";
        $made_edits = 1;
        print "Found: $trimmed_line\n";
    }
    else {
        push @new_ssl_conf_lines, $line;
    }
}

#
# Write the new ssl.conf file.
#
if (!$made_edits) {
    print "No changes required to $ssl_conf_file\n";
    exit_normally();
}

backup_file($ssl_conf_file);

print "Patching: $ssl_conf_file\n";
if (open my $fh, '>', $ssl_conf_file) {
    print {$fh} (join q(), @new_ssl_conf_lines);
    close $fh;
}
else {
    die "Error: Unable to write: $ssl_conf_file\n";
}

print "Finished patching $ssl_conf_file\n";
exit_normally();
