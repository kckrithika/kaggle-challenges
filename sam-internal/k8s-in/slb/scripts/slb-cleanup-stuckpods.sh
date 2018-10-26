#!/bin/bash

# This script attempts to delete slb pods stuck in the Terminating or Unknown state. Such pods can negatively
# impact rolling updates by causing the whole update to get stuck waiting for the pods to become healthy.

set -o errexit
set -o nounset
set -o pipefail
set -o verbose

while true
do
    # Get all the SLB pods in the sam-system namespace.
    slb_pods=$(kubectl get pods -n sam-system -o wide --no-headers | grep slb)
    # Get the subset of pods in the "Unknown" state. Ignore failures if there are no such pods.
    unknown_pods=$(echo "$slb_pods" | grep Unknown || true)
    # Get the subset of pods in the "Terminating" state where no IP address is assigned.
    # Ignore failures if there are no such pods.
    unscheduled_terminating_pods=$(echo "$slb_pods" | grep Terminating | grep '<none>' || true)

    # Delete unknown pods, if any.
    if [[ ! -z $unknown_pods ]]
    then
        pod_names=$(echo "$unknown_pods" | awk '{ print $1 "\n" }')
        echo Deleting Unknown SLB pods:
        echo $pod_names
        echo $pod_names | xargs kubectl -n sam-system delete pod --grace-period=0 --force
    fi

    # Delete unscheduled terminating pods, if any.
    if [[ ! -z $unscheduled_terminating_pods ]]
    then
        pod_names=$(echo "$unscheduled_terminating_pods" | awk '{ print $1 "\n" }')
        echo Deleting unscheduled Terminating SLB pods:
        echo $pod_names
        echo $pod_names | xargs kubectl -n sam-system delete pod --grace-period=0 --force
    fi

    sleep 600
done
