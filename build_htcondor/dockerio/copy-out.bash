#!/usr/bin/env bash

case $PKGTYPE in
	targz)
		sudo cp /home/build/*.tar.gz /mnt
                filename=$(ls /mnt/*.tar.gz)
		IFS='-' read -r -a fileparts <<< "$filename"
		newfilename="${fileparts[0]}-${fileparts[1]-$fileparts[2]}-sib-x86_64_RedHat${EL_MAJOR_VERSION}-${fileparts[4]}"
		mv $filename $newfilename 
		;;
	rpm)
		sudo cp /home/build/build/packaging/rpm/.*/RPMS/x86_64/*.rpm /mnt
		;;
	*)
		if [ -z $PKGTYPE ]; then
			echo "Please specify 'targz' or 'rpm'."
			exit 1
		fi
esac
