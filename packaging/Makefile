# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2020 Software Assurance Marketplace

#
# Determines the release and build numbers. Set these in the environment.
#
export RELEASE_NUMBER ?= 0.1
export BUILD_NUMBER ?= 1

#
# Determines the variant of the SWAMP-in-a-Box "backend" RPM to build.
# Invoke the 'singleserver' target to build the "singleserver" variant.
#
export SIB_VERSION ?= distribution

#
# Determines where to stage the source files for an RPM.
# This will be set by the targets below, as needed.
#
export STAGING_AREA ?= STAGING_AREA_NEEDS_TO_BE_SET

#
# Determines whether to exclude the larger assessment frameworks.
# Set this to "yes" in the environment to exclude them.
#
export SKIP_LARGE_FRAMEWORKS ?= no

#
# Define the commands for manipulating files and directories.
#
# Tell 'rsync' to:
#     -q  Be quiet
#     -r  Recurse into directories
#     -l  Copy symlinks as symlinks
#     -p  Preserve permissions
#     -D  Preserve device files and special files
#     -t  Preserve times
#     -S  Handle sparse files efficiently
#
CP    := rsync -qrlpDtS
MKDIR := mkdir -p
MV    := mv

#
# Define the directories containing the SWAMP's source code.
#
TOPDIR       := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
WORKSPACE    := $(realpath $(TOPDIR)/../..)
DB           := $(WORKSPACE)/db
DEPLOYMENT   := $(WORKSPACE)/deployment
PROPRIETARY  := $(WORKSPACE)/proprietary
SERVICES     := $(WORKSPACE)/services
WEB_BACKEND  := $(WORKSPACE)/swamp-web-server
WEB_FRONTEND := $(WORKSPACE)/www-front-end

############################################################################

#
# The SWAMP's "inventory" files are used to specify which versions of
# various components to include in the RPMs. Here, we process the files
# for relevant version strings.
#
SEDVER := sed -E -e 's/^([^0-9]*)([0-9]+([.][0-9]+)*)(.*)$$/\2/'

DEPENDENCIES          := $(DEPLOYMENT)/inventory/dependencies.txt
FRAMEWORKS            := $(DEPLOYMENT)/inventory/frameworks.txt
METRIC_TOOLS          := $(DEPLOYMENT)/inventory/tools-metric.txt
VIEWERS               := $(DEPLOYMENT)/inventory/viewers.txt

C_ASSESS_VERSION      := $(shell grep c-assess      $(FRAMEWORKS)   | $(SEDVER))
JAVA_ASSESS_VERSION   := $(shell grep java-assess   $(FRAMEWORKS)   | $(SEDVER))
RUBY_ASSESS_VERSION   := $(shell grep ruby-assess   $(FRAMEWORKS)   | $(SEDVER))
SCRIPT_ASSESS_VERSION := $(shell grep script-assess $(FRAMEWORKS)   | $(SEDVER))

CLOC_VERSION          := $(shell grep cloc          $(METRIC_TOOLS) | $(SEDVER))
CODE_DX_VERSION       := $(shell grep codedx        $(VIEWERS)      | $(SEDVER))
HTCONDOR_VERSION      := $(shell grep condor        $(DEPENDENCIES) | $(SEDVER))
PERL_VERSION          := $(shell grep perlbin       $(DEPENDENCIES) | $(SEDVER))
RESULTPARSER_VERSION  := $(shell grep resultparser  $(FRAMEWORKS)   | $(SEDVER))

############################################################################

#
# When invoked without a specific target, do not build anything.
#
default all:
	@echo    "Error: Not a \"real\" target: $@"    1>&2
	@echo    ""                                    1>&2
	@echo    "Perhaps try one of the following:"   1>&2
	@echo    "    mir-swamp"                       1>&2
	@echo    "    swampinabox"                     1>&2
	@echo -n "    singleserver"                    1>&2
	@echo -e "$(patsubst %,\n    %,$(all_rpms))\n" 1>&2
	@exit 1

#
# Clean out build artifacts.
#
clean:
	rm -rf $(TOPDIR)/BUILD/*-$(RELEASE_NUMBER)
	rm -rf $(TOPDIR)/BUILDROOT/*-$(RELEASE_NUMBER)-*
	rm -rf $(TOPDIR)/SOURCES/*-$(RELEASE_NUMBER)
	@echo "*** Note: Use 'make distclean' to remove all build artifacts"

distclean:
	cd -- $(SERVICES)/perl/agents/Scarf_Parsing_C && make clean
	rm -rf $(TOPDIR)/BUILD/*
	rm -rf $(TOPDIR)/BUILDROOT/*
	rm -rf $(TOPDIR)/RPMS/*
	rm -rf $(TOPDIR)/SOURCES/*
	rm -rf $(TOPDIR)/SRPMS/*

#
# Write out computed values.
#
show_paths show_versions:
	@echo ""
	@echo "### Locations of source files"
	@echo ""
	@echo "db:             $(DB)"
	@echo "deployment:     $(DEPLOYMENT)"
	@echo "proprietary:    $(PROPRIETARY)"
	@echo "services:       $(SERVICES)"
	@echo "web-backend:    $(WEB_BACKEND)"
	@echo "web-frontend:   $(WEB_FRONTEND)"
	@echo ""
	@echo "### Version info for dependencies"
	@echo ""
	@echo "c-assess:       $(C_ASSESS_VERSION)"
	@echo "java-assess:    $(JAVA_ASSESS_VERSION)"
	@echo "ruby-assess:    $(RUBY_ASSESS_VERSION)"
	@echo "script-assess:  $(SCRIPT_ASSESS_VERSION)"
	@echo "resultparser:   $(RESULTPARSER_VERSION)"
	@echo ""
	@echo "cloc:           $(CLOC_VERSION)"
	@echo "Code Dx:        $(CODE_DX_VERSION)"
	@echo "HTCondor:       $(HTCONDOR_VERSION)"
	@echo "Perl:           $(PERL_VERSION)"

############################################################################

#
# List out the RPMs for mir-swamp.org. "Unusual" RPMs are ones with
# their own idiosyncratic ways of building their source tar files.
#
standard_swamp_rpms = swamp-dataserver swamp-exec swamp-submit swamp-web-server
unusual_swamp_rpms  = swamp-rt-perl

#
# List out the RPMs specific to SWAMP-in-a-Box. "Unusual" RPMs are ones
# with their own idiosyncratic ways of building their source tar files.
#
standard_sib_rpms   = swampinabox-backend
unusual_sib_rpms    =

#
# List out *all* the RPMs handled by this Makefile.
# These lists are used below to define various collections of targets.
#
standard_rpms       = $(standard_swamp_rpms) $(standard_sib_rpms)
unusual_rpms        = $(unusual_swamp_rpms) $(unusual_sib_rpms)
all_rpms            = $(standard_rpms) $(unusual_rpms)

############################################################################

#
# Define targets for building the mir-swamp.org RPMs, the SWAMP-in-a-Box
# "distribution" RPMs, and the SWAMP-in-a-Box "singleserver" RPMs.
#
mir-swamp: swamp-rt-perl swamp-dataserver swamp-exec swamp-submit swamp-web-server

swampinabox: swamp-rt-perl swampinabox-backend swamp-web-server

singleserver:
	SIB_VERSION=singleserver make swampinabox

#
# The recipe for each RPM is to build the source tar file, and then use
# 'rpmbuild' to build the RPM from its '.spec' file.
#
$(all_rpms): %: %-source
	rpmbuild --verbose --clean --define '_topdir $(TOPDIR)' -bb SPECS/$@.spec

#
# The recipe for building each source tar file is more easily understood
# if we define a few target-specific variables.
#
$(foreach rpm,$(all_rpms),$(rpm)-source): \
	name = $(patsubst %-source,%,$@)

$(foreach rpm,$(all_rpms),$(rpm)-source): \
	full_name = $(name)-$(RELEASE_NUMBER)

$(foreach rpm,$(all_rpms),$(rpm)-source): \
	staging_area = $(TOPDIR)/SOURCES/$(full_name)

#
# The recipe for building each source tar file is to create a fresh build
# directory, stage files into it, and then create the tar file. Most of the
# RPM-specific logic is thus pushed into the 'stage-...' targets.
#
# We ensure that STAGING_AREA is set correctly for all the staging targets
# by "recursively" invoking 'make' with STAGING_AREA set in the environment.
#
$(foreach rpm,$(standard_rpms),$(rpm)-source):
	@echo ""
	@echo "### Target: $@"
	@echo ""
	rm -rf $(staging_area)
	$(MKDIR) $(staging_area)

	STAGING_AREA=$(staging_area) make stage-$@
	$(TOPDIR)/SPECS/fix-files.bash $(staging_area)
	$(TOPDIR)/SPECS/fix-permissions.bash $(staging_area)

	tar -c -f $(TOPDIR)/SOURCES/$(full_name).tar -C $(TOPDIR)/SOURCES $(full_name)

#
# The SWAMP's Perl runtime RPM is essentially already maintained as its own
# object in source control. We only need to copy the source tar file to the
# expected location.
#
swamp-rt-perl-source:
	@echo ""
	@echo "### Target: $@"
	@echo ""
	$(CP) \
	    $(DEPLOYMENT)/perl/perlbin_exec_w-$(PERL_VERSION).tar.gz \
	    $(TOPDIR)/SOURCES/$(full_name).tar.gz

############################################################################

stage-swamp-dataserver-source: stage-backend-etc stage-rpm-scriptlet-utils

	cd -- $(SERVICES)/perl/agents/Scarf_Parsing_C && make
	$(MKDIR) $(STAGING_AREA)/opt/swamp/bin
	$(CP) \
	    $(SERVICES)/perl/agents/Scarf_Parsing_C/vmu_Scarf_CParsing \
	    $(STAGING_AREA)/opt/swamp/bin
	strip $(STAGING_AREA)/opt/swamp/bin/vmu_Scarf_CParsing
	$(MKDIR) $(STAGING_AREA)/opt/swamp/lib
	$(CP) \
	    $(SERVICES)/perl/agents/Scarf_Parsing_C/yajl/install/lib/libyajl.so* \
	    $(STAGING_AREA)/opt/swamp/lib
	strip $(STAGING_AREA)/opt/swamp/lib/libyajl.so

	$(MKDIR) $(STAGING_AREA)/etc/my.cnf.d
	$(CP) \
	    $(DEPLOYMENT)/swamp/config/data_svr/mysql_timezone.cnf \
	    $(DEPLOYMENT)/swamp/config/permissions_svr/mysql_global_settings.cnf \
	    $(STAGING_AREA)/etc/my.cnf.d

	$(MKDIR) $(STAGING_AREA)/usr/lib64/mysql/plugin
	$(CP) \
	    $(DEPLOYMENT)/lib/lib_mysqludf_sys.so \
	    $(STAGING_AREA)/usr/lib64/mysql/plugin

	$(MKDIR) $(STAGING_AREA)/usr/local/bin
	$(CP) \
	    $(DEPLOYMENT)/swamp/scripts/execute_execution_record \
	    $(DEPLOYMENT)/swamp/scripts/kill_run \
	    $(DEPLOYMENT)/swamp/scripts/launch_viewer \
	    $(STAGING_AREA)/usr/local/bin

	$(MKDIR) $(STAGING_AREA)/opt/swamp/etc
	$(CP) \
	    $(DEPLOYMENT)/swamp/config/no-build.xslt \
	    $(DEPLOYMENT)/swamp/config/Scarf_ToolList.json \
	    $(STAGING_AREA)/opt/swamp/etc

	$(MKDIR) $(STAGING_AREA)/opt/swamp/sql
	$(CP) \
	    $(DB)/"Data Server"/Assessment/assessment_procs.sql \
	    $(DB)/"Data Server"/Assessment/assessment_tables.sql \
	    $(DB)/"Data Server"/Metric/metric_procs.sql \
	    $(DB)/"Data Server"/Metric/metric_tables.sql \
	    $(DB)/"Data Server"/"Package Store"/package_store_procs.sql \
	    $(DB)/"Data Server"/"Package Store"/package_store_tables.sql \
	    $(DB)/"Data Server"/"Platform Store"/platform_store_procs.sql \
	    $(DB)/"Data Server"/"Platform Store"/platform_store_tables.sql \
	    $(DB)/"Data Server"/"Tool Shed"/tool_shed_procs.sql \
	    $(DB)/"Data Server"/"Tool Shed"/tool_shed_tables.sql \
	    $(DB)/"Data Server"/"Tool Shed"/populate_tool_metadata.sql \
	    $(DB)/"Data Server"/"Viewer Store"/install_codedx.sql \
	    $(DB)/"Data Server"/"Viewer Store"/uninstall_codedx.sql \
	    $(DB)/"Data Server"/"Viewer Store"/viewer_store_procs.sql \
	    $(DB)/"Data Server"/"Viewer Store"/viewer_store_tables.sql \
	    \
	    $(DB)/"Data Server"/sys_exec.sql \
	    $(DB)/"Data Server"/Project/project_procs.sql \
	    $(DB)/SWAMP_in_a_Box/enable_metric_runs.sql \
	    \
	    $(STAGING_AREA)/opt/swamp/sql
	$(CP) \
	    $(DB)/"Data Server"/Assessment/"populate assessment.sql" \
	    $(STAGING_AREA)/opt/swamp/sql/populate_assessment.sql
	$(CP) \
	    $(DB)/"Data Server"/"Package Store"/"populate package_store.sql" \
	    $(STAGING_AREA)/opt/swamp/sql/populate_package_store.sql
	$(CP) \
	    $(DB)/"Data Server"/"Tool Shed"/"populate tool_shed.sql" \
	    $(STAGING_AREA)/opt/swamp/sql/populate_tool_shed.sql
	$(CP) \
	    $(DB)/"Data Server"/"Viewer Store"/"populate viewer_store.sql" \
	    $(STAGING_AREA)/opt/swamp/sql/populate_viewer_store.sql

	$(MKDIR) $(STAGING_AREA)/opt/swamp/sql/platforms
	$(CP) \
	    $(DB)/"Data Server"/"Platform Store"/platforms/* \
	    $(STAGING_AREA)/opt/swamp/sql/platforms

	$(MKDIR) $(STAGING_AREA)/opt/swamp/sql/tools
	$(CP) \
	    $(DB)/"Data Server"/Metric/metric_tools/* \
	    $(DB)/"Data Server"/"Tool Shed"/tools_MIR_and_SiaB/* \
	    $(DB)/"Data Server"/"Tool Shed"/tools_MIR_only/* \
	    $(STAGING_AREA)/opt/swamp/sql/tools

	$(MKDIR) $(STAGING_AREA)/opt/swamp/sql/tools_add_on
	$(CP) \
	    $(DB)/"Data Server"/"Tool Shed"/tools_Siab_add_on/* \
	    $(STAGING_AREA)/opt/swamp/sql/tools_add_on

	$(MKDIR) $(STAGING_AREA)/opt/swamp/sql/upgrades_data
	$(CP) \
	    $(DB)/"Data Server"/upgrades/* \
	    $(STAGING_AREA)/opt/swamp/sql/upgrades_data

	$(MKDIR) $(STAGING_AREA)/opt/swamp/sql/upgrades_directory
	$(CP) \
	    $(DB)/"Directory Server"/upgrades/* \
	    $(STAGING_AREA)/opt/swamp/sql/upgrades_directory

	$(MKDIR) $(STAGING_AREA)/opt/swamp/sql/util
	$(CP) \
	    $(DB)/"Data Server"/"Platform Store"/delete_platforms.sql \
	    $(DB)/"Data Server"/"Tool Shed"/tool_install.sql \
	    $(DB)/"Data Server"/"Tool Shed"/tool_uninstall.sql \
	    $(DB)/"Data Server"/"Tool Shed"/delete_all_tools.sql \
	    $(DB)/"Data Server"/"Tool Shed"/delete_non_user_tools.sql \
	    $(STAGING_AREA)/opt/swamp/sql/util

	$(MKDIR) $(STAGING_AREA)/opt/swamp/bin
	$(CP) \
	    $(DEPLOYMENT)/swampinabox/runtime/bin/swamp_check_db_file_paths \
	    $(SERVICES)/perl/agents/swamp_config \
	    $(SERVICES)/perl/agents/vmu_calldorun.pl \
	    $(SERVICES)/perl/agents/vmu_killrun.pl \
	    $(SERVICES)/perl/agents/vmu_launchviewer.pl \
	    $(STAGING_AREA)/opt/swamp/bin

	$(MKDIR) $(STAGING_AREA)/opt/swamp/sbin
	$(CP) \
	    $(DEPLOYMENT)/swampinabox/runtime/sbin/create_mysql_root \
	    $(DEPLOYMENT)/swampinabox/runtime/sbin/create_mysql_root_cnf \
	    $(DEPLOYMENT)/swampinabox/runtime/sbin/db_support.functions \
	    $(DEPLOYMENT)/swampinabox/runtime/sbin/rebuild_platforms_db \
	    $(DEPLOYMENT)/swampinabox/runtime/sbin/rebuild_tools_db \
	    $(DEPLOYMENT)/swampinabox/runtime/sbin/swamp_manage_service \
	    $(STAGING_AREA)/opt/swamp/sbin

	$(MKDIR) $(STAGING_AREA)/opt/swamp/perl5/SWAMP
	$(CP) \
	    $(SERVICES)/perl/agents/lib/SWAMP/CodeDX.pm \
	    $(SERVICES)/perl/agents/lib/SWAMP/FrameworkUtils.pm \
	    $(SERVICES)/perl/agents/lib/SWAMP/Locking.pm \
	    $(SERVICES)/perl/agents/lib/SWAMP/PackageTypes.pm \
	    $(SERVICES)/perl/agents/lib/SWAMP/vmu_AssessmentSupport.pm \
	    $(SERVICES)/perl/agents/lib/SWAMP/vmu_Support.pm \
	    $(SERVICES)/perl/agents/lib/SWAMP/vmu_ViewerSupport.pm \
	    $(STAGING_AREA)/opt/swamp/perl5/SWAMP

	$(MKDIR) $(STAGING_AREA)/opt/swamp/log
	$(MKDIR) $(STAGING_AREA)/opt/swamp/run

############################################################################

stage-swamp-exec-source: \
		stage-codedx-vendor-files \
		stage-swamp-exec-source-without-proprietary-blobs \

stage-swamp-exec-source-without-proprietary-blobs: \
		stage-assessment-toolchain \
		stage-backend-etc \
		stage-rpm-scriptlet-utils \

	$(MKDIR) $(STAGING_AREA)/opt/swamp/libexec/condor
	$(CP) \
	    $(DEPLOYMENT)/swamp/config/libvirt_swamp_script.awk \
	    $(STAGING_AREA)/opt/swamp/libexec/condor

	$(MKDIR) $(STAGING_AREA)/opt/swamp/thirdparty/common
	$(CP) \
	    $(DEPLOYMENT)/Common/* \
	    $(STAGING_AREA)/opt/swamp/thirdparty/common

	$(MKDIR) $(STAGING_AREA)/opt/swamp/thirdparty/codedx/swamp
	$(CP) \
	    $(DEPLOYMENT)/SecureDecisions/* \
	    $(STAGING_AREA)/opt/swamp/thirdparty/codedx/swamp

	$(MKDIR) $(STAGING_AREA)/opt/swamp/bin
	$(CP) \
	    $(SERVICES)/perl/agents/arun.sh \
	    $(SERVICES)/perl/agents/swamp_config \
	    $(SERVICES)/perl/agents/vmu_MonitorAssessment.pl \
	    $(SERVICES)/perl/agents/vmu_MonitorViewer.pl \
	    $(SERVICES)/perl/agents/vmu_PostAssessment.pl \
	    $(SERVICES)/perl/agents/vmu_PostViewer.pl \
	    $(SERVICES)/perl/agents/vmu_PreAssessment.pl \
	    $(SERVICES)/perl/agents/vmu_PreViewer.pl \
	    $(SERVICES)/perl/agents/vmu_perl_launcher \
	    $(STAGING_AREA)/opt/swamp/bin

	$(MKDIR) $(STAGING_AREA)/opt/swamp/perl5/SWAMP
	$(CP) \
	    $(SERVICES)/perl/agents/lib/SWAMP/FloodlightAccess.pm \
	    $(SERVICES)/perl/agents/lib/SWAMP/FrameworkUtils.pm \
	    $(SERVICES)/perl/agents/lib/SWAMP/Libvirt.pm \
	    $(SERVICES)/perl/agents/lib/SWAMP/Locking.pm \
	    $(SERVICES)/perl/agents/lib/SWAMP/mongoDBUtils.pm \
	    $(SERVICES)/perl/agents/lib/SWAMP/PackageTypes.pm \
	    $(SERVICES)/perl/agents/lib/SWAMP/ScarfXmlReader.pm \
	    $(SERVICES)/perl/agents/lib/SWAMP/vmu_AssessmentSupport.pm \
	    $(SERVICES)/perl/agents/lib/SWAMP/vmu_Support.pm \
	    $(SERVICES)/perl/agents/lib/SWAMP/vmu_ViewerSupport.pm \
	    $(STAGING_AREA)/opt/swamp/perl5/SWAMP

	$(MKDIR) $(STAGING_AREA)/opt/swamp/log
	$(MKDIR) $(STAGING_AREA)/opt/swamp/run

stage-assessment-toolchain:
	$(MKDIR) $(STAGING_AREA)/opt/swamp/etc
	$(CP) \
	    $(DEPLOYMENT)/swamp/config/services.conf \
	    $(DEPLOYMENT)/swamp/config/services.conf.map \
	    $(STAGING_AREA)/opt/swamp/etc

	{ echo c-assess:$(C_ASSESS_VERSION) ; \
	  echo java-assess:$(JAVA_ASSESS_VERSION) ; \
	  echo ruby-assess:$(RUBY_ASSESS_VERSION) ; \
	  echo script-assess:$(SCRIPT_ASSESS_VERSION) ; \
	  echo cloc:$(CLOC_VERSION) ; \
	  echo resultparser:$(RESULTPARSER_VERSION) ; \
	} >> $(STAGING_AREA)/opt/swamp/etc/versions.txt

	$(MKDIR) $(STAGING_AREA)/opt/swamp/thirdparty
	$(CP) \
	    /swampcs/releases/c-assess-$(C_ASSESS_VERSION).tar.gz \
	    $(STAGING_AREA)/opt/swamp/thirdparty/c-assess.tar.gz
	[ $(SKIP_LARGE_FRAMEWORKS) = yes ] || $(CP) \
	    /swampcs/releases/java-assess-$(JAVA_ASSESS_VERSION).tar \
	    $(STAGING_AREA)/opt/swamp/thirdparty/java-assess.tar
	[ $(SKIP_LARGE_FRAMEWORKS) = yes ] || $(CP) \
	    /swampcs/releases/ruby-assess-$(RUBY_ASSESS_VERSION).tar \
	    $(STAGING_AREA)/opt/swamp/thirdparty/ruby-assess.tar
	[ $(SKIP_LARGE_FRAMEWORKS) = yes ] || $(CP) \
	    /swampcs/releases/script-assess-$(SCRIPT_ASSESS_VERSION).tar \
	    $(STAGING_AREA)/opt/swamp/thirdparty/script-assess.tar
	$(CP) \
	    /swampcs/releases/resultparser-$(RESULTPARSER_VERSION).tar \
	    $(STAGING_AREA)/opt/swamp/thirdparty/resultparser.tar

	tar -xz -O -f /swampcs/releases/cloc-$(CLOC_VERSION).tar.gz --strip-components 3 cloc-$(CLOC_VERSION)/noarch/in-files/cloc-$(CLOC_VERSION).tar.gz | tar -xz --strip-components 1 -C $(STAGING_AREA)/opt/swamp/thirdparty cloc-$(CLOC_VERSION)/cloc

stage-codedx-vendor-files:
	$(MKDIR) $(STAGING_AREA)/opt/swamp/thirdparty/codedx/swamp
	ln -s \
	    emptydb-codedx-$(CODE_DX_VERSION).sql \
	    $(STAGING_AREA)/opt/swamp/thirdparty/codedx/swamp/emptydb-codedx.sql

	$(MKDIR) $(STAGING_AREA)/opt/swamp/thirdparty/codedx/vendor
	$(CP) \
	    $(PROPRIETARY)/SecureDecisions/*.war \
	    $(STAGING_AREA)/opt/swamp/thirdparty/codedx/vendor
	ln -s \
	    codedx-$(CODE_DX_VERSION).war \
	    $(STAGING_AREA)/opt/swamp/thirdparty/codedx/vendor/codedx.war

############################################################################

stage-swamp-submit-source: stage-backend-etc stage-rpm-scriptlet-utils

	$(MKDIR) $(STAGING_AREA)/etc/init.d
	$(CP) \
	    $(DEPLOYMENT)/swamp/scripts/swampd-common \
	    $(STAGING_AREA)/etc/init.d/swamp

	$(MKDIR) $(STAGING_AREA)/opt/swamp/etc
	$(CP) \
	    $(DEPLOYMENT)/swamp/config/swampmonitor.conf \
	    $(STAGING_AREA)/opt/swamp/etc
	$(CP) \
	    $(DEPLOYMENT)/swamp/config/vmu_swamp_htcondor_submit \
	    $(STAGING_AREA)/opt/swamp/etc/vmu_htcondor_submit

	$(MKDIR) $(STAGING_AREA)/opt/swamp/bin
	$(CP) \
	    $(SERVICES)/perl/agents/swamp_config \
	    $(SERVICES)/perl/agents/vmu_AgentMonitor.pl \
	    $(SERVICES)/perl/agents/vmu_LaunchPad.pl \
	    $(SERVICES)/perl/agents/vmu_csa_agent.pl \
	    $(SERVICES)/perl/agents/vmu_swamp_monitor \
	    $(STAGING_AREA)/opt/swamp/bin

	$(MKDIR) $(STAGING_AREA)/opt/swamp/perl5/SWAMP
	$(CP) \
	    $(SERVICES)/perl/agents/lib/SWAMP/PackageTypes.pm \
	    $(SERVICES)/perl/agents/lib/SWAMP/Locking.pm \
	    $(SERVICES)/perl/agents/lib/SWAMP/vmu_Support.pm \
	    $(SERVICES)/perl/agents/lib/SWAMP/vmu_AssessmentSupport.pm \
	    $(SERVICES)/perl/agents/lib/SWAMP/vmu_ViewerSupport.pm \
	    $(STAGING_AREA)/opt/swamp/perl5/SWAMP

	$(MKDIR) $(STAGING_AREA)/opt/swamp/log
	$(MKDIR) $(STAGING_AREA)/opt/swamp/run

############################################################################

stage-swamp-web-server-source:

	$(MKDIR) $(STAGING_AREA)/var/www/html
	$(CP) \
	    $(WEB_FRONTEND)/*  \
	    $(WEB_FRONTEND)/.htaccess \
	    $(STAGING_AREA)/var/www/html
	$(MV) \
	    $(STAGING_AREA)/var/www/html/config/config.sample.json \
	    $(STAGING_AREA)/var/www/html/config/config.json

	$(MKDIR) $(STAGING_AREA)/var/www/swamp-web-server
	$(CP) \
	    $(WEB_BACKEND)/* \
	    $(WEB_BACKEND)/.htaccess \
	    $(STAGING_AREA)/var/www/swamp-web-server
	$(MV) \
	    $(STAGING_AREA)/var/www/swamp-web-server/env.sample \
	    $(STAGING_AREA)/var/www/swamp-web-server/.env

	$(MKDIR) \
	    $(STAGING_AREA)/var/www/swamp-web-server/storage/app \
	    $(STAGING_AREA)/var/www/swamp-web-server/storage/framework \
	    $(STAGING_AREA)/var/www/swamp-web-server/storage/framework/cache \
	    $(STAGING_AREA)/var/www/swamp-web-server/storage/framework/sessions \
	    $(STAGING_AREA)/var/www/swamp-web-server/storage/framework/views \
	    $(STAGING_AREA)/var/www/swamp-web-server/storage/logs

	sed \
	    -e 's/RELEASE_NUMBER/$(RELEASE_NUMBER)/' \
	    -e 's/BUILD_NUMBER/$(BUILD_NUMBER)/' \
	    -i $(STAGING_AREA)/var/www/html/version.json
	sed \
	    -e 's/RELEASE_NUMBER/$(RELEASE_NUMBER)/' \
	    -e 's/BUILD_NUMBER/$(BUILD_NUMBER)/' \
	    -i $(STAGING_AREA)/var/www/swamp-web-server/public/version.json

############################################################################

#
# Configuration files common to the data server, exec, and submit notes.
#
stage-backend-etc:
	$(MKDIR) $(STAGING_AREA)/etc/profile.d
	$(CP) \
	    $(DEPLOYMENT)/swamp/scripts/swamp.sh \
	    $(STAGING_AREA)/etc/profile.d

	$(MKDIR) $(STAGING_AREA)/opt/swamp/etc
	$(CP) \
	    $(DEPLOYMENT)/inventory/{platforms,tools}*.txt \
	    $(DEPLOYMENT)/swamp/config/{log4perl,swamp}.conf \
	    $(STAGING_AREA)/opt/swamp/etc

	{ echo htcondor:$(HTCONDOR_VERSION) ; \
	  echo perl-rpm:$(PERL_VERSION) ; \
	} >> $(STAGING_AREA)/opt/swamp/etc/dependencies.txt

	{ echo SWAMP:$(RELEASE_NUMBER)-$(BUILD_NUMBER) ; \
	} >> $(STAGING_AREA)/opt/swamp/etc/versions.txt

#
# Utility scripts invoked by the RPMs' scriptlets.
#
stage-rpm-scriptlet-utils:
	$(MKDIR) $(STAGING_AREA)/opt/swamp/sbin
	$(CP) \
	    $(DEPLOYMENT)/swampinabox/runtime/sbin/swamp_copy_config \
	    $(DEPLOYMENT)/swampinabox/runtime/sbin/swamp_patch_config \
	    $(STAGING_AREA)/opt/swamp/sbin

	$(MKDIR) $(STAGING_AREA)/opt/swamp/perl5
	$(CP) \
	    $(DEPLOYMENT)/swampinabox/runtime/perl5/* \
	    $(STAGING_AREA)/opt/swamp/perl5

############################################################################

#
# The SWAMP-in-a-Box "backend" is a combination of the data server, exec,
# and submit nodes, with some tweaks to the configuration templates and some
# additional "runtime" files for managing the system.
#
stage-swampinabox-backend-source: \
		stage-backend-etc \
		stage-rpm-scriptlet-utils \
		stage-swamp-dataserver-source \
		stage-swamp-exec-source-without-proprietary-blobs \
		stage-swamp-submit-source

	[ $(SIB_VERSION) != distribution ] \
	  || make stage-sib-distribution-config

	[ $(SIB_VERSION) != singleserver ] \
	  || make stage-sib-singleserver-config stage-codedx-vendor-files

	$(MKDIR) $(STAGING_AREA)/opt/swamp
	$(CP) \
	    $(DEPLOYMENT)/swampinabox/runtime/* \
	    $(STAGING_AREA)/opt/swamp

	$(MKDIR) $(STAGING_AREA)/opt/swamp/etc
	$(CP) \
	    $(DEPLOYMENT)/swamp/config/vmu_swampinabox_htcondor_submit \
	    $(STAGING_AREA)/opt/swamp/etc/vmu_htcondor_submit

	$(MKDIR) $(STAGING_AREA)/opt/swamp/sql
	$(CP) \
	    $(DB)/"Directory Server"/project_procs.sql \
	    $(DB)/"Directory Server"/project_tables.sql \
	    $(DB)/SWAMP_in_a_Box/*.sql \
	    $(STAGING_AREA)/opt/swamp/sql
	$(CP) \
	    $(DB)/"Directory Server"/"populate project.sql" \
	    $(STAGING_AREA)/opt/swamp/sql/populate_project.sql

	$(MKDIR) $(STAGING_AREA)/opt/swamp/thirdparty/codedx/vendor

stage-sib-distribution-config:
	$(MKDIR) $(STAGING_AREA)/opt/swamp/etc
	$(CP) \
	    $(DEPLOYMENT)/swamp/config/swamp.conf.swampinabox \
	    $(STAGING_AREA)/opt/swamp/etc/swamp.conf
	$(CP) \
	    $(DEPLOYMENT)/swamp/config/services.conf.swampinabox \
	    $(STAGING_AREA)/opt/swamp/etc/services.conf

stage-sib-singleserver-config:
	$(MKDIR) $(STAGING_AREA)/opt/swamp/etc
	$(CP) \
	    $(DEPLOYMENT)/swamp/config/swamp.conf.singleserver \
	    $(STAGING_AREA)/opt/swamp/etc/swamp.conf
	$(CP) \
	    $(DEPLOYMENT)/swamp/config/services.conf.singleserver \
	    $(STAGING_AREA)/opt/swamp/etc/services.conf
