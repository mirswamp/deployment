# This makefile creates the swamp-dashboard RPM
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

TARBALL=SOURCES/swamp.tar

rpm: dirs $(TARBALL) 
	/bin/rm -rf RPMS/noarch
	RELEASE_NUMBER=$(RELEASE_NUMBER) BUILD_NUMBER=$(BUILD_NUMBER) TOPDIR="$(PWD)" make -C SPECS  

.PHONY dirs:

$(TARBALL): SOURCES/composer 
	$(TAR) -C ../../../dashboard-server --xform='s/^\./dashboard-server/' --exclude='.git'  --exclude='.svn' -rf ../../../deployment/swamp/dashboard-installer/$@ .
	$(TAR) -rf $@ -C SOURCES composer

dirs: $(DIRS)

SOURCES/composer: ../scripts/composer.phar.ac497feabaa0d247c441178b7b4aaa4c61b07399
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
	-sudo rpm -vv -e swamp-dashboard
	sudo rpm -vv --nodeps -i RPMS/noarch/swamp-dashboard-$(RELEASE_NUMBER)-$(BUILD_NUMBER).noarch.rpm

yuminstall: rpm
	sudo yum -y remove swamp-dashboard
	sudo rm -rf /var/www/dashboard-server
	sudo yum -y install RPMS/noarch/swamp-dashboard-$(RELEASE_NUMBER)-$(BUILD_NUMBER).noarch.rpm

tests:
	/usr/local/bin/bats --tap testdashboard > dashboard.tap

