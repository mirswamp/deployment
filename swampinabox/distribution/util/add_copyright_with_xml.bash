#!/bin/bash

SOURCE_FILE="$1"
TMP_FILE="/tmp/$USER.$(basename "$SOURCE_FILE").$RANDOM"

if [ ! -e "$SOURCE_FILE" ]; then
    echo "Error: $SOURCE_FILE does not exist"
    exit 1
fi

clear

echo ""
echo "-----------------------------------------------------------------"
echo ">>> $SOURCE_FILE"
echo "-----------------------------------------------------------------"
head -n 18 "$SOURCE_FILE"
echo "-----------------------------------------------------------------"

echo ""
echo -n "Add notice to this file? [N/y] "

read answer
if [ "$answer" != "y" ]; then
    echo ""
    echo "Not modifying $source_file"
    exit 0
fi

echo ""
echo -n "Skip how many lines? "
read skip_lines

if [ -z "$skip_lines" ]; then
    skip_lines=0
fi

cp -f "$SOURCE_FILE" "$TMP_FILE"  # capture the file's permission bits

head -n "$skip_lines" "$SOURCE_FILE" > "$TMP_FILE"

if [ "$skip_lines" -gt 0 ]; then
    echo "" >> "$TMP_FILE"
fi

echo "<!--" >> "$TMP_FILE"
echo "    This file is subject to the terms and conditions defined in" >> "$TMP_FILE"
echo "    'LICENSE.txt', which is part of this source code distribution." >> "$TMP_FILE"
echo "" >> "$TMP_FILE"
echo "    Copyright 2012-2017 Software Assurance Marketplace" >> "$TMP_FILE"
echo "-->" >> "$TMP_FILE"
echo "" >> "$TMP_FILE"

tail -n +"$(($skip_lines + 1))" "$SOURCE_FILE" >> "$TMP_FILE"

mv -f "$TMP_FILE" "$SOURCE_FILE"
