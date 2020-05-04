# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

.PHONY: install rpm perl

install: rpm
rpm: perl

perl:
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swamp-rt-perl.spec
