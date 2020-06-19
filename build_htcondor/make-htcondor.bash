#!/usr/bin/env bash

CONDOR_PKG_TYPE=targz
EL_MAJOR_VERSION=7
docker run --rm \
           -e "PKGTYPE=${CONDOR_PKG_TYPE}" \
           -e "EL_MAJOR_VERSION=${EL_MAJOR_VERSION}" \
           -v ${PWD}/dockerio:/mnt \
           -it htcondor/build-centos${EL_MAJOR_VERSION} /bin/bash -c \
"(cd htcondor; patch -p1 -i docs/old-sphinx.patch; make -C docs man); cmake3 -Wno-dev -GNinja -DCONDOR_PACKAGE_BUILD:BOOL=OFF -DCONDOR_STRIP_PACKAGES:BOOL=ON -DWITH_CREAM:BOOL=OFF -DWITH_SCITOKENS:BOOL=OFF -DWITH_MUNGE:BOOL=OFF -DWITH_GLOBUS:BOOL=OFF -DWITH_VOMS:BOOL=OFF -DDOCKER_ALLOW_RUN_AS_ROOT:BOOL=ON -DBUILDID:STRING=sib -DCMAKE_INSTALL_PREFIX:PATH=/home/build/release_dir htcondor ; ninja-build install/strip ; /mnt/ninja-build.bash ; /mnt/copy-out.bash ; /bin/bash -i"
