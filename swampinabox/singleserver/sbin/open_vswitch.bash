#!/bin/bash

# This file is subject to the terms and conditions defined in
# 'LICENSE.txt', which is part of this source code distribution.
#
# Copyright 2012-2019 Software Assurance Marketplace

modprobe openvswitch
chkconfig openvswitch on
service openvswitch start
ovs-vsctl init
ovs-vsctl add-br br-ext
VLAN_eth1=`ifconfig | grep 'eth1\.' | sed -e 's/^eth1.\([0-9]*\) Link.*$/\1/'`
ovs-vsctl add-br br-ext.$VLAN_eth1 br-ext $VLAN_eth1
ovs-vsctl add-port br-ext.$VLAN_eth1 eth1.$VLAN_eth1
