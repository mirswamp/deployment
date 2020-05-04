# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

package SWAMP::SiB_Utilities;

use utf8;
use strict;
use warnings;

use parent qw(Exporter);
our @EXPORT_OK = qw(
  do_command
  exit_normally
  exit_abnormally

  escape_dquotes
  escape_squotes
  make_shell_arg
  quote_for_laravel_55
  trim

  backup_file
  read_file
  write_file

  get_key_val
  merge_key_val
  remove_temp_objects
);
our %EXPORT_TAGS = (all => \@EXPORT_OK);
our $VERSION = '1.34';

use Carp;
use English qw( -no_match_vars );
use File::Copy qw(copy);
use POSIX qw(strftime);

############################################################################

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
# Exit with a status of 0 (zero).
#
sub exit_normally {
    main::do_cleanup() if exists &main::do_cleanup;
    exit 0;
}

#
# Exit with a status of 1.
#
sub exit_abnormally {
    my ($message, $details) = @_;
    $message = trim($message);
    $details = trim($details);

    if (defined $message) {
        print "Error: $message";
        print " ($details)" if defined $details;
        print "\n";
    }
    main::do_cleanup() if exists &main::do_cleanup;
    exit 1;
}

############################################################################

#
# Return the given string with all double quotes backslash escaped.
#
sub escape_dquotes {
    my ($val) = @_;
    if (defined $val) {
        $val =~ s/"/\\"/g;
    }
    return $val;
}

#
# Return the given string with all single quotes backslash escaped.
#
sub escape_squotes {
    my ($val) = @_;
    if (defined $val) {
        $val =~ s/'/\\'/g;
    }
    return $val;
}

#
# Return the given string single quoted for the shell.
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
# Return the given string double quoted for Laravel 5.5.
#
sub quote_for_laravel_55 {
    my ($val) = @_;
    if (   defined $val
        && ($val =~ /\s/)
        && ($val !~ /^["].*["]$/))    # do not mangle double-quoted values
    {
        $val =~ s/\\/\\\\/g;
        $val =~ s/"/\\"/g;
        $val = qq("$val");
    }
    return $val;
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

############################################################################

#
# Create a backup of the given file.
#
sub backup_file {
    my ($path) = @_;
    copy($path, $path . q(.) . strftime('%Y%m%d%H%M%S', localtime))
      or croak "Error: Failed to create a backup of: $path";
    return;
}

#
# Return the contents of the given file as a string.
#
sub read_file {
    my ($path) = @_;
    local $INPUT_RECORD_SEPARATOR = undef;
    open(my $fh, '<', $path)
      or croak "Error: Failed to open: $path";
    my $contents = <$fh>;
    close($fh)
      or croak "Error: Failed to close: $path";
    return $contents;
}

#
# Write out the given string into the given file.
#
sub write_file {
    my ($path, $contents) = @_;
    open(my $fh, '>', $path)
      or croak "Error: Failed to open: $path";
    print {$fh} $contents
      or croak "Error: Failed to write: $path";
    close($fh)
      or croak "Error: Failed to close: $path";
    return;
}

############################################################################

#
# Return the value for a key in the given string of "key = value" pairs.
#
sub get_key_val {
    my ($config, $key) = @_;
    my $key_re = "[ \t]*" . (quotemeta $key) . "[ \t]*[=]";

    my @vals = ($config =~ /^$key_re(.*)$/m);
    return $vals[0];
}

#
# Add/update a key-value pair in the given string of "key = value" pairs.
#
sub merge_key_val {
    my ($config, $key, $val, $options) = @_;
    my $eq_sym = q(=);
    my $key_re = "[ \t]*" . (quotemeta $key) . "[ \t]*[=]";

    if (!$options->{'no-space'}) {
        $eq_sym = q( = );
        $val    = trim($val);
    }
    if ($options->{'quote-for-laravel-55'}) {
        $val = quote_for_laravel_55($val);
    }

    if ($config =~ /^$key_re/m) {
        $config =~ s/^$key_re(.*)$/$key$eq_sym$val/gm;
    }
    else {
        $config .= "\n" if $config !~ /\n$/;
        $config .= "$key$eq_sym$val\n";
    }
    return $config;
}

#
# Remove the paths listed in the given array reference.
#
sub remove_temp_objects {
    my ($objects_ref) = @_;
    while (scalar @{$objects_ref} > 0) {
        my $object = pop @{$objects_ref};
        if (-f $object) {
            unlink($object)
              or carp "Error: Failed to remove file: $object";
        }
        elsif (-d $object) {
            rmdir($object)
              or carp "Error: Failed to remove directory: $object";
        }
        elsif (-e $object) {
            carp "Error: Not sure how to remove: $object";
        }
    }
    return;
}

1;
