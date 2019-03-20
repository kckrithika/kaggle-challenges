#!/usr/bin/bash
set -o nounset
set -o errexit
set -o pipefail

# Disable use of SAM's custom kubeconfig, restore default Kubernetes behavior (this cluster's kubeapi using service account token)
unset KUBECONFIG

# Parse command line arguments. https://stackoverflow.com/a/14203146
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --kubeconfig)
    # Use a custom kubeconfig (e.g. to access via MadDog PKI certs and Impersonation Proxy)
    export KUBECONFIG="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

kcfw() {
  kubectl -n flowsnake-watchdog "$@"
}

events() {
    # awk magic prints lines after search term found: https://stackoverflow.com/a/17988834
    kcfw describe sparkapplication $APP_NAME | awk '/Events:/{flag=1;next}flag'
}

SPEC=$1
APP_NAME=$(python -c 'import json,sys; print json.load(sys.stdin)["metadata"]["name"]' < $SPEC)
SELECTOR="sparkoperator.k8s.io/app-name=$APP_NAME"

# ------ Clean up ---------
echo "Cleaning up $APP_NAME resources from prior runs"
# || true because exit code 1 if spark application can't be found.
kcfw delete sparkapplication $APP_NAME || true
# kubectl returns success even if no pods match the label selector. This is helpful,
# this will have the side-effect of aborting the script early if it cannot access kubeapi.
kcfw delete pod -l $SELECTOR
# Wait for pods from prior runs to delete.
while ! $(kcfw get pod -l $SELECTOR 2>&1 | grep "No resources" > /dev/null); do sleep 1; done;

# ------ Run ---------
echo "Creating SparkApplication $APP_NAME"
kcfw create -f $SPEC
START_TIME=$SECONDS

echo "Waiting for SparkApplication $APP_NAME to terminate."
# Terminal values are COMPLETED and FAILED https://github.com/GoogleCloudPlatform/spark-on-k8s-operator/blob/master/docs/design.md#the-crd-controller
i=0
while ! $(kcfw get sparkapplication $APP_NAME -o jsonpath='{.status.applicationState.state}' | grep -P '(COMPLETED|FAILED)' > /dev/null); do
    ((i = i + 1))
    sleep 1;
    if ((i % 60 == 0)); then
        echo "...still waiting after $i seconds. Events so far:";
        events;
    fi;
done;

# ------ Report Results ---------
ELAPSED_SECS=$(($SECONDS - $START_TIME))
echo "SparkApplication $APP_NAME has terminated after $ELAPSED_SECS seconds. State is $(kcfw get sparkapplication $APP_NAME -o jsonpath='{.status.applicationState.state}'). Events:"
events

POD=$(kcfw get pod -l $SELECTOR -o name)
if [[ -z $POD ]]; then
    echo "Cannot locate driver pod. Maybe it never started? No logs to display."
else
    echo ---- Begin $POD Log ----
    kcfw logs $POD || true
    echo ---- End Spark Driver Log ----
    echo
fi
# Alternatively, generate a Splunk link? Not sure there's a good way to filter for this particular execution, since the driver pod
# has the same name on every invocation on every fleet.

# Test successful iff final state is COMPLETED. Use exit code from grep.
kcfw get sparkapplication $APP_NAME -o jsonpath='{.status.applicationState.state}' | grep COMPLETED > /dev/null
