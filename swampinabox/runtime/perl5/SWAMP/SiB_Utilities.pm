# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2018 Software Assurance Marketplace

package SWAMP::SiB_Utilities;

use utf8;
use strict;
use warnings;

use parent qw(Exporter);
our @EXPORT_OK = qw(
  do_command
  escape_dquotes
  escape_squotes
  trim
  make_shell_arg
  remove_temp_objects
  read_file
  write_file
);
our %EXPORT_TAGS = (all => \@EXPORT_OK);
our $VERSION = '1.34';

use English qw( -no_match_vars );

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
# Remove the files and directories listed in the given array.
#
sub remove_temp_objects {
    my ($objects_ref) = @_;
    while (scalar @{$objects_ref} > 0) {
        my $object = pop @{$objects_ref};
        if (-f $object) {
            unlink($object)
              || print "Error: Failed to remove file: $object\n";
        }
        elsif (-d $object) {
            rmdir($object)
              || print "Error: Failed to remove directory: $object\n";
        }
        elsif (-e $object) {
            print "Error: Not sure how to remove: $object\n";
        }
    }
    return;
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

#
# Write out the given string as the given file (path).
#
sub write_file {
    my ($path, $contents) = @_;
    open(my $fh, '>', $path) || die "Error: Failed to open: $path\n";
    print {$fh} $contents || die "Error: Failed to write: $path\n";
    close($fh) || die "Error: Failed to close: $path\n";
    return;
}

1;
