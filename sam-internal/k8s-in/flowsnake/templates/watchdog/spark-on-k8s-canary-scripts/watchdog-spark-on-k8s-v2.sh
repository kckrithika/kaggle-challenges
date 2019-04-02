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

format() {
    sed -e "s/^/$(date +'%m%d %H:%M:%S') [$(epoch)] $APP_NAME - /"
}

log() {
    if [[ "$@" != "" ]]; then
        echo "${@}" | format
    fi
}

# Run kubectl in namespace. Prefer kcfw_log when possible
kcfw() {
  kubectl -n flowsnake-watchdog "$@"
}

# Run kubectl in namespace, plus prefix output to disambiguate interleaving later
kcfw_log() {
  # pipefail is set, so sed won't lose any failure exit code returned by kubectl
  kcfw "$@" 2>&1 | format
}

events() {
    # awk magic prints lines after search term found: https://stackoverflow.com/a/17988834
    kcfw_log describe sparkapplication $APP_NAME | awk '/Events:/{flag=1;next}flag'
}

log "Beginning $APP_NAME test"
# Sanity-check kubeapi connectivity
kcfw_log cluster-info

# ------ Clean up ---------
log "Cleaning up $APP_NAME resources from prior runs"
# || true because exit code 1 if spark application can't be found.
kcfw_log delete sparkapplication $APP_NAME || true
# kubectl returns success even if no pods match the label selector. But it seems you get an
# error if you match a pod and then that pod exits on its own at just the wrong time. So || true here too.
kcfw_log delete pod -l $SELECTOR || true
# Wait for pods from prior runs to delete.
while ! $(kcfw_log get pod -l $SELECTOR | grep "No resources" > /dev/null); do sleep 1; done;

# ------ Run ---------
log "Creating SparkApplication $APP_NAME"
kcfw_log create -f $SPEC
START_TIME=$(epoch)

# Terminal values are COMPLETED and FAILED https://github.com/GoogleCloudPlatform/spark-on-k8s-operator/blob/master/docs/design.md#the-crd-controller
state() {
    kcfw get sparkapplication $APP_NAME -o jsonpath='{.status.applicationState.state}'
}

declare -A PREVIOUS_POD_PHASES # pod name -> pod phase
report_pod_changes() {
    unset POD_PHASES
    declare -A POD_PHASES # pod name -> pod phase
    # Fetch pod names and their status for this SparkApplication in format <pod_name>:<pod_status> ...
    # Relevant pods for our spark application have label metadata.labels.spark-app-selector=$APP_ID
    for POD_AND_PHASE in $(kcfw get pods -l${SELECTOR} --show-all -o template --template '{{ range .items }}{{ .metadata.name }}{{":"}}{{ .status.phase }}{{" "}}{{ end }}' | xargs -n1); do
        # crack pod:phase into key,value and add to map
        POD_PHASES["$(echo ${POD_AND_PHASE} | cut -d: -f1)"]="$(echo ${POD_AND_PHASE} | cut -d: -f2)"
    done;

    # ${!MY_MAP[@]} yields the keys of the associative array
    # Bash array set operations: See https://unix.stackexchange.com/a/104848
    REMOVED_POD_NAMES=$(comm -23 <(echo ${!PREVIOUS_POD_PHASES[@]} | xargs -n1 | sort) <(echo ${!POD_PHASES[@]} | xargs -n1 | sort))
    NEW_POD_NAMES=$(comm -13 <(echo ${!PREVIOUS_POD_PHASES[@]} | xargs -n1 | sort) <(echo ${!POD_PHASES[@]} | xargs -n1 | sort))
    EXISTING_POD_NAMES=$(comm -12 <(echo ${!PREVIOUS_POD_PHASES[@]} | xargs -n1 | sort) <(echo ${!POD_PHASES[@]} | xargs -n1 | sort))

    # Can't simply copy associative arrays in bash, so perform maintenance on PREVIOUS_POD_PHASES as we go.
    for POD_NAME in ${REMOVED_POD_NAMES}; do
        log "Pod ${POD_NAME} removed."
        unset PREVIOUS_POD_PHASES["$POD_NAME"]
    done
    for POD_NAME in ${NEW_POD_NAMES}; do
        log "Pod ${POD_NAME} created: ${POD_PHASES["${POD_NAME}"]}.";
        PREVIOUS_POD_PHASES["$POD_NAME"]=${POD_PHASES["${POD_NAME}"]}
    done;
    for POD_NAME in ${EXISTING_POD_NAMES}; do
        OLD_STATUS="${PREVIOUS_POD_PHASES[${POD_NAME}]}"
        NEW_STATUS="${POD_PHASES[${POD_NAME}]}"
        if [[ "${OLD_STATUS}" != "${NEW_STATUS}" ]]; then
            log "Pod ${POD_NAME} phase changed to ${NEW_STATUS} (previously ${OLD_STATUS})."
            PREVIOUS_POD_PHASES["$POD_NAME"]="${NEW_STATUS}"
        fi
    done;
}

LAST_LOGGED=$(epoch)
log "Waiting for SparkApplication $APP_NAME to terminate."
STATE=$(state)
while ! $(echo ${STATE} | grep -P '(COMPLETED|FAILED)' > /dev/null); do
    EPOCH=$(epoch)
    if (( EPOCH - START_TIME >= TIMEOUT_SECS )); then
        log "Timeout reached. Aborting wait even though in non-terminal state $STATE."
        events;
        break
    fi
    if (( EPOCH - LAST_LOGGED > 180 )); then
        log "...still waiting for terminal state (currently $STATE) after $((EPOCH-START_TIME)) seconds. SparkApplication Events so far:";
        events;
        LAST_LOGGED=${EPOCH}
    fi;
    report_pod_changes
    sleep 1;
    STATE=$(state)
done;
report_pod_changes

# ------ Report Results ---------
END_TIME=$(epoch)
ELAPSED_SECS=$(($END_TIME - $START_TIME))
EXIT_CODE=$(echo $STATE | grep COMPLETED > /dev/null; echo $?)
log "SparkApplication $APP_NAME has terminated after $ELAPSED_SECS seconds. State is $STATE. Events:"
events

POD=$(kcfw get pod -l ${SELECTOR},spark-role=driver -o name)
if [[ -z $POD ]]; then
    log "Cannot locate driver pod. Maybe it never started? No logs to display."
else
    log ---- Begin $POD Log ----
    kcfw logs $POD || true
    log ---- End $POD Log ----
fi
# Alternatively, generate a Splunk link? Not sure there's a good way to filter for this particular execution, since the driver pod
# has the same name on every invocation on every fleet.

log "Completion of $APP_NAME test, returning $EXIT_CODE"
exit $EXIT_CODE
