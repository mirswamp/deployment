DOCROOT ?= doxygen
.PHONY: doc clean

doc:
	(cat dox_agentmonitor; echo OUTPUT_DIRECTORY=$(DOCROOT)/dox_agentmonitor) | doxygen -
	(cat dox_launchpad; echo OUTPUT_DIRECTORY=$(DOCROOT)/dox_launchpad) | doxygen -
	(cat dox_assessmentTask ; echo OUTPUT_DIRECTORY=$(DOCROOT)/dox_assessmentTask) | doxygen -
	(cat dox_domainMonitor ; echo OUTPUT_DIRECTORY=$(DOCROOT)/dox_domainMonitor) | doxygen -
	(cat dox_csa_HTCondoragent ; echo OUTPUT_DIRECTORY=$(DOCROOT)/dox_csa_HTCondoragent) | doxygen -
	(cat dox_csa_agent ; echo OUTPUT_DIRECTORY=$(DOCROOT)/dox_csa_agent) | doxygen -
	(cat dox_javacode ; echo OUTPUT_DIRECTORY=$(DOCROOT)/dox_javacode) | doxygen -
	(cat dox_php_perm ; echo OUTPUT_DIRECTORY=$(DOCROOT)/dox_php_perm) | doxygen -
	(cat dox_php_dir ; echo OUTPUT_DIRECTORY=$(DOCROOT)/dox_php_dir) | doxygen -


clean:
	@rm -rf ./doxygen
	@mkdir doxygen
