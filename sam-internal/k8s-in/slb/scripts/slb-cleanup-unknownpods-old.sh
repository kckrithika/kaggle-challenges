#!/bin/bash -xe
while true
do
    unknownpodcount=`kubectl get pods -n sam-system | grep slb | grep Unknown |wc -l`

    if [ $unknownpodcount -gt 0 ]
    then
        kubectl get pods -n sam-system | grep slb | grep Unknown | sed 's/ .*//'g | xargs kubectl -n sam-system delete pod --grace-period=0 --force
    fi

    sleep 600
done
