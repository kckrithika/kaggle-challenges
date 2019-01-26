#!/bin/bash

# This script attempts to periodically kill systemd-journald on nodes that are running a patch set with a known
# memory leak in that process.

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

# Set the interval at which this script will check for stuck SLB pods.
interval_in_seconds=14400 # 4 hours

# Check whether we are currently on the impacted patch set.
function is_2019_0116_patch() {
    [[ $(rpm -q sfdc-release) == "sfdc-release-2019.0116-01.ce7.x86_64" ]]
}

# kill_journald_loop is the core worker loop of this script. It periodically 
function kill_journald_loop() {
    while true
    do
        sleep "$interval_in_seconds"

        if [[ !is_2019_0116_patch ]]; then
            echo "Host is not on the impacted patch set. Skipping."
            continue
        fi

        echo "Killing journald"
        kill -9 $(pidof systemd-journald)
    done
}

function main() {
    kill_journald_loop
}

main