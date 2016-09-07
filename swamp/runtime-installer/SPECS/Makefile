install: rpms
rpms: java perl

java:
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swamp-rt-java.spec
perl:
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swamp-rt-perl.spec
