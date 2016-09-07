# This makefile creates the swamp-web-server RPM
DIRS=SOURCES RPMS BUILD
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
	$(TAR) -C ../../../www-front-end --xform='s/^\./html/' --exclude='.git'  --exclude='.svn' -rf ../../../deployment/swamp/swamp-web-server-installer/$@ .
	$(TAR) -C ../../../swamp-web-server --xform='s/^\./swamp-web-server/' --exclude='.git'  --exclude='.svn' -rf ../../../deployment/swamp/swamp-web-server-installer/$@ .
	$(TAR) -rf $@ -C SOURCES composer

dirs: $(DIRS)

# Replace the text 'BUILD_VERSION' in version.js with the actual build version.
version: 
	$(TAR) --delete -vf $(TARBALL) html/scripts/version.js
	mkdir -p SOURCES/html/scripts
	sed -e's#BUILD_VERSION#$(RELEASE_NUMBER).$(BUILD_NUMBER)#' ../../../www-front-end/scripts/version.js > SOURCES/html/scripts/version.js
	$(TAR) -rf $(TARBALL) -C SOURCES html
	/bin/rm -rf SOURCES/html


SOURCES/composer: ../scripts/composer.phar.c33c5196b19c77ea89b05a81c573d88543d3a93d
	/bin/cp $< $@

RPMS:
	mkdir -p $@
SOURCES:
	mkdir -p $@
	touch $@/Makefile
BUILD:
	mkdir -p $@

clean:
	rm -rf SOURCES RPMS BUILD BUILDROOT SRPMS

install: clean rpm
	sudo yum -y remove swamp-web-server
	sudo yum -y install RPMS/noarch/swamp-web-server-$(RELEASE_NUMBER)-$(BUILD_NUMBER).noarch.rpm

tests:
	/usr/local/bin/bats --tap testswampweb > swampweb.tap
