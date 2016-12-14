#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

#
# Remove files that are left over from older releases of SWAMP-in-a-Box.
#

#
# 1.27.* -> 1.28.1: Remove deprecated and old platforms and tools.
#
for file_to_remove in \
        /swamp/platforms/images/condor-debian-7.0-64-master-2015012801.qcow2 \
        /swamp/platforms/images/condor-dynamic-centos-6.8-64-viewer-master-2016080901.qcow2 \
        /swamp/platforms/images/condor-fedora-19.0-64-master-2015012801.qcow2 \
        /swamp/platforms/images/condor-scientific-5.9-64-master-2015012801.qcow2 \
        /swamp/platforms/images/condor-scientific-6.4-64-master-2015071401.qcow2 \
        /swamp/platforms/images/condor-ubuntu-12.04-64-master-2015012801.qcow2 \
        /swamp/store/SCATools/bandit/bandit-8ba3536-3.tar.gz \
        /swamp/store/SCATools/bandit/bandit-py2-0.14.0-2.tar.gz \
        /swamp/store/SCATools/bandit/bandit-py3-0.14.0-2.tar.gz \
        /swamp/store/SCATools/clang/clang-sa-3.3.tar \
        /swamp/store/SCATools/clang/clang-sa-3.7.0.tar \
        /swamp/store/SCATools/clang/clang-sa-3.8.0.tar \
        /swamp/store/SCATools/cloc/cloc-1.64-3.tar \
        /swamp/store/SCATools/cppcheck/cppcheck-1.61.tar \
        /swamp/store/SCATools/cppcheck/cppcheck-1.70.tar \
        /swamp/store/SCATools/cppcheck/cppcheck-1.71.tar \
        /swamp/store/SCATools/cppcheck/cppcheck-1.72.tar \
        /swamp/store/SCATools/cppcheck/cppcheck-1.73.tar \
        /swamp/store/SCATools/lizard/lizard-1.10.4-3.tar \
        ; do

    if [ -e "$file_to_remove" ]; then
        echo "Removing $file_to_remove"
        rm -f "$file_to_remove"
    fi
done
