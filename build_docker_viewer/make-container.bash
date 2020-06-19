#!/usr/bin/env bash
# Codedx version number
BUILDDATE=$(date +%Y%m%d)
BUILDREV=00
CODEDX_WAR_VERSION=$(grep codedx ../inventory/viewers.txt | sed 's/codedx-//' | sed 's/.war//')
TOMCAT_VERSION=8.5.49

# copy files outside the docker build tree
cp ../../proprietary/SecureDecisions/codedx-${CODEDX_WAR_VERSION}.war .
cp -r ../Common .
cp -r ../SecureDecisions .
# build the base container without the war file:
docker build -t swamp/codedx-viewer-base \
	--build-arg CODEDX_WAR_VERSION=$CODEDX_WAR_VERSION \
	--build-arg TOMCAT_VERSION=$TOMCAT_VERSION \
	-f ./Dockerfile-codedx-no-warfile .
# add in the war file:
docker build -t swamp/condor-codedx-${CODEDX_WAR_VERSION}-viewer-master-${BUILDDATE}${BUILDREV} \
	--build-arg CODEDX_WAR_VERSION=$CODEDX_WAR_VERSION \
	-f ./Dockerfile-codedx-add-warfile .
rm codedx-${CODEDX_WAR_VERSION}.war
rm -r Common
rm -r SecureDecisions
