rpms: submit exec dataserver dirserver
	
swamponabox-files.txt:	common-files-*.txt swamponabox-files-*.txt
	cat $^ | grep -v "^\s*\#" | sort -u > $@

swamponabox-install.txt:	common-install-*.txt swamponabox-install-*.txt
	cat $^ | sort -u | grep "^mkdir" > $@
	cat $^ | grep -v "^\s*\#" | sort -u | grep -v "^mkdir" >> $@

swamponabox-nothreadfix-install.txt:	common-install-*.txt swamponabox-install-*.txt
	cat $^ | sort -u | grep "^mkdir" | grep -v threadfix > $@
	cat $^ | sort -u | grep -v "^mkdir" | grep -v threadfix >> $@
	mv $@ swamponabox-install.txt

singleserver: clean swamponabox-files.txt swamponabox-install.txt
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swamponabox-backend.spec

swamponabox: clean swamponabox-files.txt swamponabox-nothreadfix-install.txt
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swamponabox-backend.spec

dirserver:
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swamp-directory.spec

dataserver:
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swamp-ds.spec  

exec:
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swamp-exec.spec  

submit:
	rpmbuild --verbose --define '_topdir $(TOPDIR)' -bb swamp-submit.spec  

clean:
	rm -f swamponabox-files.txt swamponabox-install.txt swamponabox-nothreadfix-install.txt
