# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

DIRS=SOURCES
RELEASE_NUMBER ?= 0.13
BUILD_NUMBER ?= dev

CP=/bin/cp -p
TAR=tar

PERL_RPM_VERSION=$(shell grep perlbin ../../inventory/dependencies.txt)

.PHONY: dirs rpm perl

rpm: dirs perl

perl: dirs SOURCES/perlbin.tgz
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS perl

SOURCES/perlbin.tgz: SOURCES
	$(CP) -r ../../perl/$(PERL_RPM_VERSION) SOURCES/perlbin.tgz

dirs: $(DIRS)
$(DIRS):
	mkdir -p $@

clean:
	rm -rf SOURCES BUILD BUILDROOT RPMS SRPMS *.tap
