#!/bin/bash

CURRENT_RELEASE_NUMBER=`curl -s http://swa-build-1/config.xml | grep RELEASE_NUMBER | sed -e "s/^.*RELEASE_NUMBER=//" | sed -e "s/.DEV.*$//"`

echo $CURRENT_RELEASE_NUMBER

