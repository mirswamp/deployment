#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

#
# Download the most recent SWAMP-in-a-Box release.
#

unset CDPATH
BINDIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
DOWNLOAD_W_CONTINUE=""
DOWNLOAD_WO_CONTINUE=""
DOWNLOAD_TO_STDOUT=""
PLATFORM_BASE_URL=https://platform.swampinabox.org/siab-latest-release

############################################################################

function exit_with_error {
    echo "" 1>&2
    echo "Error: Something unexpected happened, downloads are NOT complete" 1>&2
    exit 1
}

function remove_file {
    path=$1
    if [ -e "$path" ]; then
        echo "Removing $path"
        rm -f "$path"
    fi
}

############################################################################

#
# Determine how to download files and whether we can verify checksums.
#

echo -n "Checking for curl ... "
which curl
curl_ok=$?

echo -n "Checking for wget ... "
which wget
wget_ok=$?

echo -n "Checking for md5sum ... "
which md5sum
md5sum_ok=$?

if [ $curl_ok -eq 0 ]; then
    DOWNLOAD_W_CONTINUE="curl --fail -O -C -"
    DOWNLOAD_WO_CONTINUE="curl --fail -O"
    DOWNLOAD_TO_STDOUT="curl --fail"
elif [ $wget_ok -eq 0 ]; then
    DOWNLOAD_W_CONTINUE="wget --continue"
    DOWNLOAD_WO_CONTINUE="wget"
    DOWNLOAD_TO_STDOUT="wget -O -"
fi

if [ -z "$DOWNLOAD_TO_STDOUT" ]; then
    echo "" 1>&2
    echo "Error: Failed to find a command for downloading files" 1>&2
    exit 1
fi

#
# Determine the SWAMP-in-a-Box version number.
#

echo "Determining SWAMP-in-a-Box version"
version=$($DOWNLOAD_TO_STDOUT "$PLATFORM_BASE_URL/version.txt")

if [[ ! ( "$version" =~ ^[[:digit:]]+.[[:digit:]]+ ) ]]; then
    echo "" 1>&2
    echo "Error: Failed to determine SWAMP-in-a-Box version (found: $version)" 1>&2
    exit 1
fi

#
# Confirm where files will be downloaded to.
#

LOCAL_DESTINATION_DIR=$BINDIR/swampinabox-$version-release

echo ""
echo "########################################################################"
echo ""
echo "The SWAMP-in-a-Box $version installer will be downloaded to:"
echo ""
echo "    $LOCAL_DESTINATION_DIR"

if [ $md5sum_ok -ne 0 ]; then
    echo "" 1>&2
    echo "Warning: 'md5sum' is not available, unable to verify downloaded files" 1>&2
fi

echo ""
echo -n "Continue with the downloads? [N/y] "
read -r answer
echo ""

if [ "$answer" != "y" ]; then
    exit 1
fi

#
# Create the directory where files will be downloaded to.
#

echo "Creating $LOCAL_DESTINATION_DIR"

mkdir -p "$LOCAL_DESTINATION_DIR" || exit_with_error
cd    -- "$LOCAL_DESTINATION_DIR" || exit_with_error

echo "Working directory is now $(pwd)"

#
# Download the list of files to download and their checksums.
#

remove_file md5sums.txt

echo ""
echo "Downloading file list"
$DOWNLOAD_WO_CONTINUE "$PLATFORM_BASE_URL/md5sums.txt" || exit_with_error

echo ""
echo "Files that will be downloaded:"
while read -r checksum filename ; do
    echo "  - $filename"
done <<< "$(cat md5sums.txt)"
echo ""

#
# Download the files themselves and verify their checksums.
#

downloads_failed=no

while read -r checksum filename ; do
    echo "Creating $filename.md5"
    echo "$checksum  $filename" > "$filename.md5"
    needs_download=yes

    #
    # Without md5sum, assume that the entire file needs to be downloaded.
    # We have no way of verifying the result of what looks like completing
    # a partial download.
    #

    if [ $md5sum_ok -eq 0 ] && [ -e "$filename" ]; then
        echo -n "Verifying checksum for $filename ... "

        if md5sum -c "$filename.md5" 1>/dev/null 2>&1 ; then
            echo "ok"
            needs_download=no
        else
            echo "failed (download required?)"
        fi
    fi

    if [ "$needs_download" = "yes" ]; then
        if [ $md5sum_ok -eq 0 ]; then
            echo "Downloading $filename"
            $DOWNLOAD_W_CONTINUE "$PLATFORM_BASE_URL/$filename"
        else
            remove_file "$filename"
            echo "Downloading $filename"
            if ! $DOWNLOAD_WO_CONTINUE "$PLATFORM_BASE_URL/$filename" ; then
                downloads_failed=yes
            fi
        fi

        if [ $md5sum_ok -eq 0 ]; then
            echo -n "Verifying checksum for $filename ... "

            if md5sum -c "$filename.md5" 1>/dev/null 2>&1 ; then
                echo "ok"
            else
                echo "failed"
                downloads_failed=yes
            fi
        fi
    fi

    remove_file "$filename.md5"
done <<< "$(cat md5sums.txt)"

#
# Post-process the downloaded files.
#

if [ -e extract-installer.bash ]; then
    echo "Making extract-installer.bash executable"
    chmod +x extract-installer.bash
fi

if [ "$downloads_failed" != "no" ]; then
    echo "" 1>&2
    echo "Error: Some files were not downloaded successfully" 1>&2
    exit 1
fi

#
# Write out final instructions.
#

echo ""
echo "########################################################################"
echo ""
echo "The SWAMP-in-a-Box installer has been downloaded to:"
echo ""
echo "    $LOCAL_DESTINATION_DIR"
echo ""
echo "To install SWAMP-in-a-Box, start by reading the administrator manual,"
echo "a copy of which can be found in the installer directory listed above."
