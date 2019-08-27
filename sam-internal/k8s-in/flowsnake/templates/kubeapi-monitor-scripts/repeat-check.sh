#!/bin/bash

set -x

REPEAT_PERIOD=30

while true; do
    /kubeapi-monitor-scripts/check-kubeapi.sh &
    sleep ${REPEAT_PERIOD}
done
