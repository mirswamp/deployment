# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

TARBALL=../SOURCES/swamp-1.tar.gz
FILES=start_vm masterify_vm vm_output vm_cleanup templ.xml
PKGS=VMTools.pm VMConstants.pm

pkgfiles:= $(PKGS:%=../../lib/%)
files:= $(FILES:%=../../%) 
#destfiles:=$(FILES:%=../SOURCES/%) $(PKGS:%=../SOURCES/%)

rpms: submit exec dataserver dirserver
	
swamponabox-files.txt:	swamponabox-files-*.txt
	cat $^ | sort -u > $@

swamponabox-install.txt:	swamponabox-install-*.txt
	cat $^ | sort -u | grep "^mkdir" > $@
	cat $^ | sort -u | grep -v "^mkdir" >> $@

swamponabox-nothreadfix-install.txt:	swamponabox-install-*.txt
	cat $^ | sort -u | grep "^mkdir" | grep -v threadfix > $@
	cat $^ | sort -u | grep -v "^mkdir" | grep -v threadfix >> $@
	mv $@ swamponabox-install.txt

singleserver: swamponabox-files.txt swamponabox-install.txt
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swampinabox-backend.spec

swamponabox: swamponabox-files.txt swamponabox-nothreadfix-install.txt
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swampinabox-backend.spec

dirserver:
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swamp-directory.spec

dataserver:
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swamp-ds.spec  

exec:
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swamp-exec.spec  

submit:
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swamp-submit.spec  

all: ../RPMS/noarch/swamp-0.9-1.noarch.rpm ../RPMS/noarch/swamp-cli-0.9-1.noarch.rpm
# Invoke as TOPDIR=$PWD/.. make
../RPMS/noarch/swamp-0.9-1.noarch.rpm: ../RPMS ../BUILD ../SRPMS swamp.spec 
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -ba swamp.spec  
../RPMS/noarch/swamp-cli-0.9-1.noarch.rpm: ../RPMS ../BUILD ../SRPMS swamp-cli.spec 
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -ba swamp-cli.spec  

../RPMS/noarch/swamp-ds-0.9-1.noarch.rpm: ../RPMS ../BUILD ../SRPMS swamp-cli.spec 
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -ba swamp-ds.spec  

#../SOURCES/%: ../../%
#	cp -pf $< $@

#../SOURCES/%: ../../lib/%
#	cp -pf $< $@

../RPMS:
	mkdir -p ../RPMS

../BUILD:
	mkdir -p ../BUILD

../SRPMS:
	mkdir -p ../SRPMS
