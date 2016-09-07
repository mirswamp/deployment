TARBALL=../SOURCES/swamp-1.tar.gz

rpms:
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swamp-dataserver-setup.spec
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swamp-directoryserver-setup.spec
	
