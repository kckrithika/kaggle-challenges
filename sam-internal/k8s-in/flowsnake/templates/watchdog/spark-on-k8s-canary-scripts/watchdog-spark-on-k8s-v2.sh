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

SPEC=$1
APP_NAME=$(python -c 'import json,sys; print json.load(sys.stdin)["metadata"]["name"]' < $SPEC)
SELECTOR="sparkoperator.k8s.io/app-name=$APP_NAME"
# Exit after 12 minutes to ensure we exit before cliChecker kills us (15 mins) so that all output can be logged.
TIMEOUT_SECS=$((60*12))

epoch() {
    date '+%s'
}

log() {
    echo "${@}" | sed -e "s/^/[$(epoch)] $APP_NAME - /"
}

# Run kubectl in namespace, plus prefix output to disambiguate interleaving later
kcfw() {
  # pipefail is set, so sed won't lose any failure exit code returned by kubectl
  kubectl -n flowsnake-watchdog "$@" 2>&1 | log
}

events() {
    # awk magic prints lines after search term found: https://stackoverflow.com/a/17988834
    kcfw describe sparkapplication $APP_NAME | awk '/Events:/{flag=1;next}flag'
}

log "Beginning $APP_NAME test"
# ------ Clean up ---------
log "Cleaning up $APP_NAME resources from prior runs"
# || true because exit code 1 if spark application can't be found.
kcfw delete sparkapplication $APP_NAME || true
# kubectl returns success even if no pods match the label selector. This is helpful,
# this will have the side-effect of aborting the script early if it cannot access kubeapi.
kcfw delete pod -l $SELECTOR
# Wait for pods from prior runs to delete.
while ! $(kcfw get pod -l $SELECTOR | grep "No resources" > /dev/null); do sleep 1; done;

# ------ Run ---------
log "Creating SparkApplication $APP_NAME"
kcfw create -f $SPEC
START_TIME=$(epoch)

log "Waiting for SparkApplication $APP_NAME to terminate."
# Terminal values are COMPLETED and FAILED https://github.com/GoogleCloudPlatform/spark-on-k8s-operator/blob/master/docs/design.md#the-crd-controller
i=0
state() {
    kcfw get sparkapplication $APP_NAME -o jsonpath='{.status.applicationState.state}'
}
STATE=state
while ! $(echo $STATE | grep -P '(COMPLETED|FAILED)' > /dev/null); do
    if ((i % 180 == 0)); then
        log "...still waiting for terminal state (currently $STATE) after $i seconds. Events so far:";
        events;
    fi;
    EPOCH=epoch
    if [[ $((EPOCH - START_TIME)) >= $TIMEOUT_SECS ]]; then
        log "Timeout reached. Aborting wait even though in non-terminal state $STATE."
        break
    fi
    ((i = i + 1))
    sleep 1;
    STATE=state
done;

# ------ Report Results ---------
END_TIME=$(epoch)
ELAPSED_SECS=$(($END_TIME - $START_TIME))
EXIT_CODE=$(echo $STATE | grep COMPLETED > /dev/null)
log
log "SparkApplication $APP_NAME has terminated after $ELAPSED_SECS seconds. State is $STATE. Events:"
events

POD=$(kcfw get pod -l ${SELECTOR},spark-role=driver -o name)
if [[ -z $POD ]]; then
    log "Cannot locate driver pod. Maybe it never started? No logs to display."
else
    log
    log ---- Begin $POD Log ----
    kcfw logs $POD || true
    log ---- End $POD Log ----
    log
fi
# Alternatively, generate a Splunk link? Not sure there's a good way to filter for this particular execution, since the driver pod
# has the same name on every invocation on every fleet.

log "Completion of $APP_NAME test, returning $EXIT_CODE"
return $EXIT_CODE
