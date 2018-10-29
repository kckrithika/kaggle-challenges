#!/bin/bash

# This script attempts to delete slb pods stuck in the Terminating or Unknown state. Such pods can negatively
# impact rolling updates by causing the whole update to get stuck waiting for the pods to become healthy.

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

# Set the interval at which this script will check for stuck SLB pods.
interval_in_seconds=600

# delete_pods deletes the pods passed as argument $1 (in kubectl get pods --no-headers format).
# Argument $2 supplies the type of pod being deleted (for display only).
function force_delete_pods() {
    pod_listing=$1
    stuck_pod_type=$2

    pod_names=$(echo "$pod_listing" | awk '{ print $1 "\n" }')
    echo "Force-deleting $stuck_pod_type SLB pods:"
    echo "$pod_names"
    echo "$pod_names" | xargs kubectl -n sam-system delete pod --grace-period=0 --force
}

# delete_stuck_pods_loop is the core worker loop of this script. It periodically gets the listing of slb pods,
# checks for any that are stuck, and then force-deletes those pods.
function delete_stuck_pods_loop() {
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
            force_delete_pods "$unknown_pods" "Unknown"
        fi

        # Delete unscheduled terminating pods, if any.
        if [[ ! -z $unscheduled_terminating_pods ]]
        then
            force_delete_pods "$unscheduled_terminating_pods" "unscheduled Terminating"
        fi

        echo "$(date +'%Y-%m-%d %T') Sleeping for $interval_in_seconds seconds."
        sleep "$interval_in_seconds"
    done
}

function main() {
    delete_stuck_pods_loop
}

main