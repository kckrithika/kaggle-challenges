#!/bin/bash

set -x

TIMEOUT_PERIOD=10

timeout ${TIMEOUT_PERIOD} curl -s -ik ${KUBE_API_ADDRESS}/version && echo
STATUS_API=$?

if [ ${STATUS_API} -eq 0 ]; then
    METRIC_VALUE=1
else
    METRIC_VALUE=0
    # When timed out, exit code is 124
    echo "Failed to reach to the api server - command exit code ${STATUS_API}"
fi

echo "Publishing the result ${METRIC_RESULT} to the Funnel endpoint..."

METRICS_PUBLISH_PATH=${FUNNEL_ENDPOINT}${METRICS_URL_PATH}?${METRICS_PUBLISH_KEY}=${METRICS_SCHEMA_FINGERPRINT}
METRIC_SERVICE=flowsnake
METRIC_SUBSERVICE=kubeapi-monitor
METRIC_NAME=${ESTATE}.KubeApiserver.Success
METRIC_TIMESTAMP=$(date +%s)

METRIC='[{"service":"'${METRIC_SERVICE}'","subservice":"'${METRIC_SUBSERVICE}'","tags":{"datacenter":"'${KINGDOM}'","superpod":"none","node":"'${NODE_NAME}'"},"metricName":["'${METRIC_NAME}'"],"metricValue":'${METRIC_VALUE}',"timestamp":'${METRIC_TIMESTAMP}'}]'

timeout ${TIMEOUT_PERIOD} curl -s -X POST -H Content-Type:application/json ${METRICS_PUBLISH_PATH} -d ${METRIC} && echo
STATUS_FUNNEL=$?

if [ ${STATUS_FUNNEL} -ne 0 ]; then
    echo "Failed to publish metric to the Funnel endpoint - exit code ${STATUS_FUNNEL}"
    echo "Quitting with exit code ${STATUS_FUNNEL}..."
    exit ${STATUS_FUNNEL}
fi
