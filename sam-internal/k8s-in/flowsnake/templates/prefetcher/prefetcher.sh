#! /bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)
IMAGE_FILE=${SCRIPT_DIR}/prefetch_images.txt
STASHED_SCRIPT_FILE=/root/.prefetcher.sh.copy

if [ -z "${FUNNEL_ENDPOINT}" ] ; then
    echo "Environment variable FUNNEL_ENDPOINT not set"
    exit 2
fi

if [ -z "${KINGDOM}" ] ; then
    echo "Environment variable KINGDOM not set"
    exit 2
fi

if [ -z "${ESTATE}" ] ; then
    echo "Environment variable ESTATE not set"
    exit 2
fi

if [ -z "${NODE_NAME}" ] ; then
    echo "Environment variable NODE_NAME not set"
    exit 2
fi


FUNNEL_URL="${FUNNEL_ENDPOINT}/funnel/v1/publishBatch?avroSchemaFingerprint=AVG7NnlcHNdk4t_zn2JBnQ"

# stash a copy of ourselves for later reference
cp "$0" "${STASHED_SCRIPT_FILE}"

post_to_funnel () {
    ERR_CT=${1}
    METRIC_TIMESTAMP=$(date +%s)
    METRIC_VAL=$( cat <<EOF
      [
        {
          "service":"flowsnake",
          "subservice":"image-prefetcher",
          "tags": {
            "datacenter":"${KINGDOM}",
            "pod":"${ESTATE}",
            "host":"${NODE_NAME}"
          },
          "metricName": ["FlowsnakeDockerImagePrefetcher.failureCount"],
          "metricValue": ${ERR_CT},
          "timestamp": ${METRIC_TIMESTAMP}
        }
     ]
EOF
)
    HTTP_STATUS=$(timeout 10 curl -sSi -w '%{http_code}' -o /tmp/flowsnake-prefetcher-response.txt -XPOST -H "Content-Type: application/json" --data-binary "${METRIC_VAL}" "${FUNNEL_URL}" 2> /tmp/flowsnake-prefetcher-stderr.txt)
    CURL_STATUS="$?"
    echo
    if [ "${CURL_STATUS}" == "124" ] ; then
        echo "WARNING: Timed out posting to Funnel"
    elif [ "${CURL_STATUS}" != "0" ] ; then
        echo "WARNING: Error posting to Funnel at URL ${FUNNEL_URL} . curl error message:"
        cat  /tmp/flowsnake-prefetcher-stderr.out
    elif [ "${HTTP_STATUS}" != "200" ] ; then
        echo "WARNING: Funnel returned status ${HTTP_STATUS}. Response:"
        cat /tmp/flowsnake-prefetcher-response.txt
    fi
}

while true; do

    # When the configmap with this script is updated, the pod running it won't necessarily be restarted.
    # So detect changes and force a restart here.
    if ! diff -q "$0" "${STASHED_SCRIPT_FILE}" > /dev/null ; then
        echo Script change detected - exiting
        exit 0
    fi
    
    FAILED_IMAGE_CT=0
    echo "Starting image prefetch at $(date)"
    for img in $(cat ${IMAGE_FILE}) ; do
        docker -H unix:///host-var-run/docker.sock pull "${img}"
        if [ "$?" != "0" ] ; then
            FAILED_IMAGE_CT=$((FAILED_IMAGE_CT + 1))
        fi
    done

    post_to_funnel ${FAILED_IMAGE_CT}

    sleep $((RANDOM % 20 + 50))m

done
