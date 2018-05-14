#!/bin/bash -xe
while true
do
    # Cleanup unknown pods
    kubectl get pods -n sam-system | grep slb | grep Unknown | sed 's/ .*//'g | xargs kubectl -n sam-system delete pod --grace-period=0 --force
    sleep 600
done
