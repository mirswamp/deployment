#!/usr/bin/env bash

case $PKGTYPE in
	targz)
		ninja-build targz
		;;
	rpm)
		sudo yum install -y python-sphinx python-sphinx_rtd_theme
                sed -i 's/trap/#trap/g' ./htcondor/build/packaging/srpm/makesrpm.sh
                ninja-build rpm
		;;
	*)
		if [ -z $PKGTYPE ]; then
			echo "Please specify 'targz' or 'rpm'."
			exit 1
		fi
esac
