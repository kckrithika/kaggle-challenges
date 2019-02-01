#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

function update_hosts() {
    host=$1
    override=$2
    hosts_file_path="/etc/hosts"
    ip=$(dig +short ${override} | head -n 1)
    if [ -z "$ip" ]; then
         echo "failed to resolve $override"
         return 0;
    fi

    line="$ip\t$host"
    if [ -n "$(grep ${host} ${hosts_file_path})" ]; then
         echo "$host is already in hosts file"
         return 0;
    fi

    echo "Adding $line to $hosts_file_path"
    echo "${line}" >> ${hosts_file_path}
}

function update_hosts_loop() {
    $h=$1
    $o=$2
    interval_in_seconds=$3

    while true
    do
      update_hosts ${h} ${o}
      sleep "$interval_in_seconds"
    done
}

update_hosts $1 $2 $3