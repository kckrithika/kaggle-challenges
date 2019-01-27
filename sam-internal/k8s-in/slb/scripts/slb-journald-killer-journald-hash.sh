#!/bin/bash

# This script attempts to periodically kill systemd-journald on nodes that are running a patch set with a known
# memory leak in that process.

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

# Set the interval at which this script will check for stuck SLB pods.
interval_in_seconds=14400 # 4 hours

# Define a splay window between .9 * interval_in_seconds and 1.1 * interval_in_seconds.
# Don't want all nodes restarting systemd-journald at the same time.
window_start=$(((interval_in_seconds*9)/10))
window_width=$(((interval_in_seconds*2)/10))

# Check whether we are currently on the bad journald version.
function is_journald_at_bad_version() {
    [[ $(sha256sum /host-systemd/systemd-journald | awk '{print $1}') == "756726577e2e92be38e3aa86e785fba1acc73ede06c3e3db450036ad6d0ca069" ]]
}

# kill_journald_loop is the core worker loop of this script. It sleeps for a period of time before checking whether
# this host is on the bad journald version. If so, it proceeds to kill the systemd-journald process.
function kill_journald_loop() {
    while true
    do
        sleep_period=$(((RANDOM%window_width)+window_start))
        echo "Sleeping for $sleep_period seconds"
        sleep "$sleep_period"

        # Skip if this host is not running the 2019.0116 patch.
        if ! is_journald_at_bad_version; then
            echo "Host is not on the impacted journald version. Skipping."
            continue
        fi

        journald_pid=$(ps -ef | grep -v grep | grep systemd-journald | awk '{print $2}')

        [[ -z $journald_pid ]] && continue

        echo "Killing journald"
        kill -9 "$journald_pid"
    done
}

function main() {
    kill_journald_loop
}

main