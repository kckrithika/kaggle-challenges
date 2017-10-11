#!/bin/bash -xe

hostname=$(hostname)

while true
do
    # Cleanup SLB logs
    rm /slb/* | true
    sleep 1800
done
