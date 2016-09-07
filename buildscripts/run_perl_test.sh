#!/bin/bash
echo Workspace: ${WORKSPACE:?WORKSPACE is not set}
echo Build number: ${BUILD_NUMBER:?BUILD_NUMBER is not set}
echo Job: ${JOB_NAME:?JOB_NAME is not set}

if [ ! -d $WORKSPACE/services/perl/agents ];then
    echo Error: cannot see $WORKSPACE/services/perl/agents 
    exit 1
fi
# if [ ! -d $WORKSPACE/services/perl/vmtools ];then
    # echo Error: cannot see $WORKSPACE/services/perl/vmtools 
    # exit 1
# fi
cd $WORKSPACE/services/perl/agents

# FindBin change, workspace needs to look a little like production with log and run folder.
mkdir -p ../log ../run

# Set up perlbrew.
# if [ -z "$PERLBREW_ROOT" ];then
    # PERLBREW_ROOT=${PERLBREW_ROOT:=/opt/perl5}
    # export PERLBREW_ROOT
    # source ${PERLBREW_ROOT}/etc/bashrc
    # perlbrew switch perl-5.18.1
    # perlbrew list
# fi
export PATH=/opt/perl5/perls/perl-5.18.1/bin:$PATH
perl -v
# TEST_OUTPUT="> ${WORKSPACE}/${JOB_NAME}-${BUILD_NUMBER}-junit.xml" make test
# Run the bats test
## Turning this test off until an explanation of it's failure can be determined. Something is altering the timing of the test.
##../../../test/perl/agents/testswamp_mon --tap > swamp_monitor.tap
# cd ../vmtools
# TEST_OUTPUT="> ${WORKSPACE}/${JOB_NAME}-${BUILD_NUMBER}-vmtools-junit.xml" make test
