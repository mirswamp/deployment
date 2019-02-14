# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

rpms: submit exec dataserver dirserver

swampinabox-files.txt: common-files-*.txt swampinabox-files-*.txt
	cat $^ | grep -v "^\s*\#" | sort -u > $@

swampinabox-install.txt: common-install-*.txt swampinabox-install-*.txt
	cat $^ | sort -u | grep "^mkdir" > $@
	cat $^ | grep -v "^\s*\#" | sort -u | grep -v "^mkdir" >> $@

singleserver: clean swampinabox-files.txt swampinabox-install.txt
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swampinabox-backend.spec

swampinabox: clean swampinabox-files.txt swampinabox-install.txt
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swampinabox-backend.spec

dirserver:
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swamp-directory.spec

dataserver:
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swamp-ds.spec

exec:
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swamp-exec.spec

submit:
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swamp-submit.spec

clean:
	rm -f swampinabox-files.txt swampinabox-install.txt
