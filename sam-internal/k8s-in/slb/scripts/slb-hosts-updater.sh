#!/bin/bash

# This script adds the given entry to the hosts file
# Usage: ./slb-hosts-updater.sh <host> <host to override with> <interval>
# Example usage: ./slb-hosts-updater.sh ops0-artifactrepo2-0-prd.data.sfdc.net ops0-artifactrepo2-0-prd.prd.r.data.sfdc.net 30

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

function update_hosts() {
    host=$1
    override=$2
    hosts_file_path="/etc/hosts"
    ip=$(dig +short "${override}" | head -n 1)
    if [ -z "$ip" ]; then
         echo "failed to resolve $override"
         return
    fi

    line="$ip $host"
    if grep -q "${host}" "${hosts_file_path}"; then
         echo "$host is already in hosts file"
         return
    fi

    echo "Adding $line to $hosts_file_path"
    echo "${line}" >> ${hosts_file_path}
}

function update_hosts_loop() {
    interval_in_seconds=$3

    while true
    do
      update_hosts "$1" "$2"
      echo "Sleeping for $interval_in_seconds seconds."
      sleep "$interval_in_seconds"
    done
}

update_hosts_loop "$1" "$2" "$3"