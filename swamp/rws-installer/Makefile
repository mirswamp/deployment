# This makefile creates the swamp-rws RPM
DIRS=SOURCES RPMS SPECS BUILD
RELEASE_NUMBER ?= 0.15
BUILD_NUMBER ?= dev

CP=/bin/cp -p
ifeq ($(shell uname), Darwin) 
TAR=gnutar
else
TAR=tar
endif
TOP= ../../..

TARBALL=SOURCES/swamp-1.tar

rpm: dirs $(TARBALL) version
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS  

.PHONY dirs:

$(TARBALL): SOURCES/composer 
	$(TAR) -C ../../../web/www-front-end --xform='s/^\./html/' --exclude='.git'  --exclude='.svn' -rf ../../../deployment/swamp/rws-installer/$@ .
	$(TAR) -C ../../../web/rws --xform='s/^\./rws/' --exclude='.git'  --exclude='.svn' -rf ../../../deployment/swamp/rws-installer/$@ .
	$(TAR) -rf $@ -C SOURCES composer

dirs: $(DIRS)

# Replace the text 'BUILD_VERSION' in version.js with the actual build version.
version: 
	$(TAR) --delete -vf $(TARBALL) html/scripts/version.js
	mkdir -p SOURCES/html/scripts
	sed -e's#BUILD_VERSION#$(RELEASE_NUMBER).$(BUILD_NUMBER)#' ../../../web/www-front-end/scripts/version.js > SOURCES/html/scripts/version.js
	$(TAR) -rf $(TARBALL) -C SOURCES html
	/bin/rm -rf SOURCES/html


SOURCES/composer: ../scripts/composer.phar.c33c5196b19c77ea89b05a81c573d88543d3a93d
	/bin/cp $< $@

RPMS:
	mkdir -p $@
SPECS:
	mkdir -p $@
SOURCES:
	mkdir -p $@
	touch $@/Makefile

BUILD:
	mkdir -p $@

clean:
	rm -rf SOURCES RPMS BUILD BUILDROOT

install: rpm
	sudo yum -y remove swamp-registry-web-server
	sudo yum -y install RPMS/noarch/swamp-registry-web-server-$(RELEASE_NUMBER)-$(BUILD_NUMBER).noarch.rpm

tests:
	/usr/local/bin/bats --tap testrwsweb > rwsweb.tap
