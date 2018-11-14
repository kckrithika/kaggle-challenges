#!/bin/bash

# This script periodically deletes log files at the given path
# Example usage: ./slb-cleanup-log /var/log/kern.*
#                ./slb-cleanup-log /data/slb/log/slb-iface-processor

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

function clean_logs() {
  logs_to_clean=$1
  echo "Removing the following files"
  rm -rfv $logs_to_clean
}

log_path=$1
interval_in_seconds=$2
while true
do
    clean_logs "$log_path"
    sleep "$interval_in_seconds"
done

