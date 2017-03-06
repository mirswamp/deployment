#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2017 Software Assurance Marketplace

BINDIR=`dirname "$0"`

PLATFORM_HOST="platform.swampinabox.org"
PLATFORM_RELEASE_DIR="siab-latest-release"
PLATFORM_BASE_URL="https://$PLATFORM_HOST/$PLATFORM_RELEASE_DIR"

function exit_with_incomplete {
    echo ""
    echo "Downloads are not complete."
    exit 1
}

function exit_with_error {
    echo ""
    echo "Error encountered. Downloads are not complete."
    exit 1
}

#
# Determine how to download files and whether we can verify checksums.
#

echo -n "Checking for wget ... "
which wget
wget_ok=$?

echo -n "Checking for curl ... "
which curl
curl_ok=$?

echo -n "Checking for md5sum ... "
which md5sum
md5sum_ok=$?

if [ $wget_ok -eq 0 ]; then
    DOWNLOAD_W_CONTINUE="wget --continue"
    DOWNLOAD_WO_CONTINUE="wget"
    DOWNLOAD_TO_STDOUT="wget -O -"
elif [ $curl_ok -eq 0 ]; then
    DOWNLOAD_W_CONTINUE="curl --fail -O -C -"
    DOWNLOAD_WO_CONTINUE="curl --fail -O"
    DOWNLOAD_TO_STDOUT="curl --fail"
fi

if [ -z "$DOWNLOAD_TO_STDOUT" ]; then
    echo ""
    echo "Error: Didn't find a suitable program for downloading files."
    exit_with_error
fi

#
# Determine the SWAMP-in-a-Box version number.
#

echo ""
echo "Determining SWAMP-in-a-Box version"
VERSION=$($DOWNLOAD_TO_STDOUT "$PLATFORM_BASE_URL/version.txt")

if [[ "$VERSION" =~ ^[0-9]+.[0-9]+ ]]; then
    echo "Found SWAMP-in-a-Box version: $VERSION"
else
    echo "Found SWAMP-in-a-Box version: (error: $VERSION)"
    exit_with_error
fi

#
# Confirm where files be downloaded to.
#

LOCAL_DESTINATION_DIR="$BINDIR/swampinabox-$VERSION-release"

echo ""
echo "The SWAMP-in-a-Box $VERSION installer will be downloaded to:"
echo "$LOCAL_DESTINATION_DIR"

if [ $md5sum_ok -ne 0 ]; then
    echo ""
    echo "Warning: md5sum is not in $USER's path. Unable to verify downloaded files."
fi

echo ""
echo -n "Continue with the downloads? [N/y] "
read ANSWER
if [ "$ANSWER" != "y" ]; then
    exit_with_incomplete
fi

echo ""
echo "Creating $LOCAL_DESTINATION_DIR"
mkdir -p "$LOCAL_DESTINATION_DIR" || exit_with_error
cd "$LOCAL_DESTINATION_DIR" || exit_with_error

echo "Current working directory:" `pwd`

#
# Download the list of files to download and their checksums.
#

if [ -e "md5sums.txt" ]; then
    echo "Removing md5sums.txt"
    rm -f md5sums.txt
fi

echo "Downloading file list"
$DOWNLOAD_WO_CONTINUE "$PLATFORM_BASE_URL/md5sums.txt" || exit_with_error

echo ""
echo "Files that will be downloaded:"

while read checksum filename; do
    echo "    $filename"
done <<< "$(cat md5sums.txt)"

echo ""

#
# Download the files themselves and verify their checksums.
#

while read checksum filename; do
    echo "$checksum  $filename" > "$filename.md5"

    needs_download="yes"

    #
    # Without md5sum, assume that the entire file needs to be downloaded.
    # We have no way of verifying the result of what looks like completing
    # a partial download.
    #

    if [ $md5sum_ok -eq 0 -a -e "$filename" ]; then
        echo -n "Verifying checksum for $filename ... "
        md5sum -c "$filename.md5" 1>/dev/null 2>/dev/null

        if [ $? -eq 0 ]; then
            echo "ok"
            needs_download="no"
        else
            echo "checksum failed (download required?)"
        fi
    fi

    if [ "$needs_download" == "yes" ]; then
        if [ $md5sum_ok -eq 0 ]; then
            echo "Downloading $filename"
            $DOWNLOAD_W_CONTINUE "$PLATFORM_BASE_URL/$filename"
        else
            if [ -e "$filename" ]; then
                echo "Removing $filename"
                rm -f "$filename"
            fi
            echo "Downloading $filename"
            $DOWNLOAD_WO_CONTINUE "$PLATFORM_BASE_URL/$filename"
        fi

        if [ $md5sum_ok -eq 0 ]; then
            echo -n "Verifying checksum for $filename ... "
            md5sum -c "$filename.md5" 1>/dev/null 2>/dev/null

            if [ $? -eq 0 ]; then
                echo "ok"
            else
                echo "checksum failed"
                downloads_failed="yes"
            fi
        fi
    fi

    echo "Removing $filename.md5"
    rm -f "$filename.md5"
done <<< "$(cat md5sums.txt)"

#
# Post-process the downloaded files.
#

if [ "$downloads_failed" == "yes" ]; then
    echo ""
    echo "Error: Some files could not be downloaded successfully."
    exit_with_error
fi

if [ -e "extract-installer.bash" ]; then
    echo ""
    echo "Making extract-installer.bash executable"
    chmod +x extract-installer.bash
fi

#
# Echo final instructions.
#

echo ""
echo ""
echo "########################################################################"
echo ""
echo "The SWAMP-in-a-Box installer has been downloaded to:"
echo "$LOCAL_DESTINATION_DIR"
echo ""
echo "To install SWAMP-in-a-Box, start by reading:"
echo "$LOCAL_DESTINATION_DIR/README-INSTALL.md"

exit 0
