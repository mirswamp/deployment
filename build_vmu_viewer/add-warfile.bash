#!/usr/bin/env bash

export LIBGUESTFS_BACKEND=direct

WARFILE=$2
QCOWFILE=$1
MNTPOINT=/tmp/mnt

if [ -r $WARFILE ]; then
        if [ -r $QCOWFILE ]; then
               
                echo "Creating mount point [${MNTPOINT}]."
                mkdir -p ${MNTPOINT}
                if [ $? != 0 ]; then
                        echo "Failed to create mount point."
                        exit 1
                fi

                echo "Mounting [${QCOWFILE}]."
                guestmount -a ${QCOWFILE} -m /dev/sda1 --rw ${MNTPOINT}
                if [ $? != 0 ]; then
                        echo "Failed to mount image."
                        exit 1
                fi

                echo "Adding ${WARFILE}"
                mkdir -p ${MNTPOINT}/opt/codedx
                unzip -q -d ${MNTPOINT}/opt/codedx ${WARFILE}

                echo "Updating CodeDX version."
                cp ${MNTPOINT}/opt/codedx/WEB-INF/classes/version.properties ${MNTPOINT}/var/lib/codedx/PROJECT/config/version.properties

                echo "Un-mounting [${QCOWFILE}]."
                umount ${MNTPOINT}
                rm -rf ${MNTPOINT}

        else
                echo "$QCOWFILE: not found"
                exit 1
        fi
else
        echo "$WARFILE: not found"
        exit 1
fi
        
