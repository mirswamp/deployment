# This makefile creates the CSA Web server RPM
DIRS=SOURCES RPMS SPECS BUILD
RELEASE_NUMBER ?= 0.17
BUILD_NUMBER ?= dev

CP=/bin/cp -p
ifeq ($(shell uname), Darwin) 
TAR=gnutar
else
TAR=tar
endif
TOP= ../../..

TARBALL=SOURCES/swamp.tar

rpm: dirs $(TARBALL) 
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS  

.PHONY dirs:

$(TARBALL): SOURCES/composer 
	$(TAR) -C ../../../web/csa --xform='s/^\./csa/' --exclude='.git' --exclude='.svn' -rf ../../../deployment/swamp/csa-web-installer/$@ .
	$(TAR) -rf $@ -C SOURCES composer

dirs: $(DIRS)

SOURCES/composer: ../scripts/composer.phar.c33c5196b19c77ea89b05a81c573d88543d3a93d
	/bin/cp $< $@

RPMS:
	mkdir -p $@
SPECS:
	mkdir -p $@
SOURCES:
	mkdir -p $@
BUILD:
	mkdir -p $@

clean:
	rm -rf SOURCES RPMS BUILD BUILDROOT

install: clean rpm
	sudo yum -y remove httpd mod_security swamp-csaweb
	sudo yum -y install RPMS/noarch/swamp-csaweb-$(RELEASE_NUMBER)-$(BUILD_NUMBER).noarch.rpm

tests:
	/usr/local/bin/bats --tap testcsaweb > csaweb.tap

$(CONFIG:%=SOURCES/%): ../config/
	$(CP) $(<)$(@:SOURCES/%=%)  $@

$(SCRIPTS:%=SOURCES/%): ../scripts/
	$(CP) $(<)$(@:SOURCES/%=%)  $@
