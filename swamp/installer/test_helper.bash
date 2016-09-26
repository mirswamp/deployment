# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2016 Software Assurance Marketplace

# Helper script to dump output from a failed bats test
dumpifnonzero() {
    if [ $status -ne 0 ];then
        echo $BATS_TEST_NAME status: $status > ${BATS_TEST_NUMBER}.bats
        echo Test named $BATS_TEST_DESCRIPTION >> ${BATS_TEST_NUMBER}.bats
        for item in ${lines[*]}
        do
            printf "%s\n" $item 
        done >> ${BATS_TEST_NUMBER}.bats
    fi
}
dumpifzero() {
    if [ $status -eq 0 ];then
        echo $BATS_TEST_NAME status: $status > ${BATS_TEST_NUMBER}.bats
        echo Test named $BATS_TEST_DESCRIPTION >> ${BATS_TEST_NUMBER}.bats
        for item in ${lines[*]}
        do
            printf "%s\n" $item 
        done >> ${BATS_TEST_NUMBER}.bats
    fi
}
dumpalways() {
	echo $BATS_TEST_NAME status: $status > ${BATS_TEST_NUMBER}.bats
	echo Test named $BATS_TEST_DESCRIPTION >> ${BATS_TEST_NUMBER}.bats
	for item in ${lines[*]}
	do
		printf "%s\n" $item 
	done >> ${BATS_TEST_NUMBER}.bats
}
