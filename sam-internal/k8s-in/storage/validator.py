#!/usr/bin/env python2.7

import os
import sys
import argparse

parser = argparse.ArgumentParser(description="Validate storage components in a given phase.")
parser.add_argument('phase', type=int, choices=range(1,4),
                    help='the phase to validate')
args = parser.parse_args()

index = args.phase - 1
command_prefix = "kubectl -s "
configs = [
    "http://shared0-storagesamkubeapi2-1-prd.eng.sfdc.net:40000/",
    "http://shared0-samkubeapi1-1-prd.eng.sfdc.net:40000",
    "http://pseudo-kubeapi.csc-sam.prd-sam.prd.slb.sfdc.net:40001/phx-sam",
    ]
lego_namespaces = [
    "ceph-prd-sam-cephdev",
    "legostore",
    "legostore",
    ]
commands = [" get deploy,ds --all-namespaces -l cloud=storage -o wide", " exec -it -n %s ceph-mon-0-0-0 -- ceph status"]
description = ["## Control plane health and version", "## Ceph cluster health"]

print("# Phase %s Cluster Validation\n" % args.phase)
for i, c in enumerate(commands):
    command = command_prefix + configs[index] + c
    temp = command
    try:
        command = command % lego_namespaces[index]
    except TypeError:
        command = temp
    print(description[i])
    print('```')
    print(command)
    os.system(command)
    print('```\n')
