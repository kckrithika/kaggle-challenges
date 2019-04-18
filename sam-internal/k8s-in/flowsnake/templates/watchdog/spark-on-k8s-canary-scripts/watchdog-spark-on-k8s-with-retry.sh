#!/usr/bin/bash
set -o nounset
set -o errexit
set -o pipefail

# Disable use of SAM's custom kubeconfig, restore default Kubernetes behavior (this cluster's kubeapi using service account token)
unset KUBECONFIG

NAMESPACE=flowsnake-watchdog
KUBECTL_TIMEOUT_SECS=10
KUBECTL_ATTEMPTS=3

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
    --namespace)
    # Use a custom namespace (default is flowsnake-watchdog)
    export NAMESPACE="$2"
    shift # past argument
    shift # past value
    ;;
    --kubectl-timeout)
    # Specify timeout (seconds) for individual kubectl invocations (default is 5)
    export KUBECTL_TIMEOUT_SECS="$2"
    shift # past argument
    shift # past value
    ;;
    --kubectl-attempts)
    # Specify number of attempts for individual kubectl invocations (default is 3)
    export KUBECTL_ATTEMPTS="$2"
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

# Check if spec is a jsonnet template
if [[ ".jsonnet" == "${1: -8}" ]] ; then
    jsonnet -V jenkinsId=${TEST_RUNNER_ID} -V dockerTag=${DOCKER_TAG} -V s3ProxyHost=${S3_PROXY_HOST} -V driverServiceAccount=${DRIVER_SERVICE_ACCOUNT} ${1} -m /strata-test-specs-out
    SPEC_INPUT=$(basename "$1")
    SPEC_NAME=${SPEC_INPUT%%.*}
    if [ -f "/strata-test-specs-out/${SPEC_NAME}.json" ]; then
        SPEC="/strata-test-specs-out/${SPEC_NAME}.json"
    else
        echo "spec /strata-test-specs-out/${SPEC_NAME}.json doesn't exist."
        exit 1
    fi
else
    # regular spec
    SPEC=$1
fi

APP_NAME=$(python -c 'import json,sys; print json.load(sys.stdin)["metadata"]["name"]' < $SPEC)
SELECTOR="sparkoperator.k8s.io/app-name=$APP_NAME"
# Exit after 9 minutes to ensure we exit before cliChecker kills us (10 mins) so that all output can be logged.
TIMEOUT_SECS=$((60*9))

# output Unix time to stdout
epoch() {
    date '+%s'
}

# Format string for log output by decorating with date, time, app name
format() {
    sed -e "s/^/$(date +'%m%d %H:%M:%S') [$(epoch)] $APP_NAME - /"
}

# Format and output provided string to stdout
log() {
    if [[ "$@" != "" ]]; then
        echo "${@}" | format
    fi
}

# Run kubectl in namespace.
# Use for extracting programatic values; otherwise prefer kcfw_log for formatted output.
#
# stdout is printed without change.
# stderr is log-formatted and printed.
#
# Operations are timed out after KUBECTL_TIMEOUT_SECS and retried KUBECTL_ATTEMPTS times upon timeout or non-zero exit
# Timeout and retry events are printed to stderr
kcfw() {
    ATTEMPT=1
    while true; do
        tmpfile=$(mktemp /tmp/$(basename $0)-stderr.XXXXXX)
        timeout --signal=9 ${KUBECTL_TIMEOUT_SECS} kubectl -n ${NAMESPACE} $@ 2>$tmpfile
        RESULT=$?
        # Format captured stderr for logging and output it to stderr
        cat $tmpfile | format >&2
        rm $tmpfile
        if [[ $RESULT == 0 ]]; then
            # Success! We're done.
            return $RESULT;
        fi;
        MSG="Invocation ($ATTEMPT/$KUBECTL_ATTEMPTS) of [$@] failed ($(if (( $RESULT == 124 || $RESULT == 137 )); then echo "timed out (${KUBECTL_TIMEOUT_SECS}s)"; else echo $RESULT; fi))."
        if (( $ATTEMPT < $KUBECTL_ATTEMPTS )); then
            log "$MSG Will sleep $KUBECTL_TIMEOUT_SECS seconds and then try again." >&2
            sleep ${KUBECTL_TIMEOUT_SECS}
        else
            log "$MSG Giving up." >&2
            return ${RESULT}
        fi;
        ATTEMPT=$(($ATTEMPT + 1))
    done;
}

# Like kcfw, plus apply log formatting to stdout.
kcfw_log() {
  # pipefail is set, so sed won't lose any failure exit code returned by kubectl
  # stderr is already formatted by kcfw, so only need to add formatting to stdout
  kcfw "$@" | format
}

# Extract the "Events" section from a kubectl description of a resource.
events() {
    # awk magic prints only lines that occur after the search term is found: https://stackoverflow.com/a/17988834
    kcfw_log describe sparkapplication $APP_NAME | awk '/Events:/{flag=1;next}flag'

    DRIVERPOD=$(kcfw get pod -l ${SELECTOR},spark-role=driver -o name)
    if [[ -n $DRIVERPOD ]]; then
        log ---- Begin $DRIVERPOD Events ----
        kcfw describe $DRIVERPOD | awk '/Events:/{flag=1;next}flag' || true
        log ---- End $DRIVERPOD Events ----
    fi

    EXECUTORPODS = $(kcfw get pod -l ${SELECTOR},spark-role=executor -o name)
    for POD_NAME in ${EXECUTORPODS}; do
        log ---- Begin $POD_NAME Events ----
        kcfw describe $POD_NAME | awk '/Events:/{flag=1;next}flag' || true
        log ---- End $POD_NAME Events ----
    done;
}

# Return the state of the Spark application.
# Terminal values are COMPLETED and FAILED https://github.com/GoogleCloudPlatform/spark-on-k8s-operator/blob/master/docs/design.md#the-crd-controller
state() {
    kcfw get sparkapplication $APP_NAME -o jsonpath='{.status.applicationState.state}'
}

# Log changes to pods spawned for SparkApplication
declare -A PREVIOUS_POD_REPORTS # pod name -> "<pod_status> on host <nodeName>"
report_pod_changes() {
    unset POD_REPORTS
    declare -A POD_REPORTS # pod name -> "<pod_name> <pod_status> on host <nodeName>"
    # Fetch pod names and their status for this SparkApplication
    # Note that the status from kubectl get contains a more informative single-term status than is available in the JSON.
    # The JSON contains the phase (Pending -> Running -> Completed), which does not mention Init, and the detailed
    # conditions and containerStatuses lists, which are difficult to summarize.
    # Relevant pods for our spark application have label metadata.labels.spark-app-selector=$APP_ID
    # Reading command ouptut line by line: https://unix.stackexchange.com/a/52027
    while read POD_REPORT; do
        POD=$(echo $POD_REPORT | cut -d' ' -f1)
        REPORT=$(echo $POD_REPORT | cut -d' ' -f1 --complement)
        POD_REPORTS["$POD"]="${REPORT}"
    done < <(kcfw get pods -l${SELECTOR} --show-all -o wide --no-headers | awk '{print $1, $3, "on host", $7}')

    # Note: Initially used process substitution (as in FOO=$(comm <(...) <(...) )here, but that left defunct grandchild
    # processes behind. Switch to temp files instead.
    # (Not totally clear on why. Something like: process substitution never collects the exit status of the invoked
    # process. Thus when the Bash script exits, the process gets re-parented to the cliChecker. But the cliChecker
    # does not collect it either, so zombie process entries pile up.)
    PREVIOUS_POD_NAMES_FILE=$(mktemp /tmp/$(basename $0)-previous-pods.XXXXXX)
    CURRENT_POD_NAMES_FILE=$(mktemp /tmp/$(basename $0)-current-pods.XXXXXX)
    # Write out the names of the pods. ${!MY_MAP[@]} yields the keys of the associative array
    echo ${!PREVIOUS_POD_REPORTS[@]} | xargs -n1 | sort > "$PREVIOUS_POD_NAMES_FILE"
    echo ${!POD_REPORTS[@]} | xargs -n1 | sort > "$CURRENT_POD_NAMES_FILE"
    # Compare pod names from before with ones present now.
    # Bash array set operations: See https://unix.stackexchange.com/a/104848
    REMOVED_POD_NAMES=$(comm -23 "$PREVIOUS_POD_NAMES_FILE" "$CURRENT_POD_NAMES_FILE")
    NEW_POD_NAMES=$(comm -13 "$PREVIOUS_POD_NAMES_FILE" "$CURRENT_POD_NAMES_FILE")
    EXISTING_POD_NAMES=$(comm -12 "$PREVIOUS_POD_NAMES_FILE" "$CURRENT_POD_NAMES_FILE")
    rm "$PREVIOUS_POD_NAMES_FILE"
    rm "$CURRENT_POD_NAMES_FILE"

    # Can't simply copy associative arrays in bash, so perform maintenance on PREVIOUS_POD_REPORTS as we go.
    for POD_NAME in ${REMOVED_POD_NAMES}; do
        log "Pod change detected: ${POD_NAME} removed."
        unset PREVIOUS_POD_REPORTS["$POD_NAME"]
    done
    for POD_NAME in ${NEW_POD_NAMES}; do
        log "Pod change detected: ${POD_NAME}: ${POD_REPORTS["${POD_NAME}"]}.";
        PREVIOUS_POD_REPORTS["$POD_NAME"]=${POD_REPORTS["${POD_NAME}"]}
    done;
    for POD_NAME in ${EXISTING_POD_NAMES}; do
        # The hostname won't change, so only report the pod status. ${VAR%% *} means delete everything after the first space
        # space. Thus "<pod_name> <pod_status> on host <nodeName>" becomes "<pod_name>"
        # http://tldp.org/LDP/abs/html/string-manipulation.html
        OLD_REPORT="${PREVIOUS_POD_REPORTS[${POD_NAME}]}"
        NEW_REPORT="${POD_REPORTS[${POD_NAME}]}"
        if [[ "${OLD_REPORT}" != "${NEW_REPORT}" ]]; then
            log "Pod change detected: ${POD_NAME} changed to ${NEW_REPORT%% *} (previously ${OLD_REPORT%% *})."
            PREVIOUS_POD_REPORTS["$POD_NAME"]="${NEW_REPORT}"
        fi
    done;
}


# ------ Initialize ---------
START_TIME=$(epoch)
log "Beginning $APP_NAME test"
# Sanity-check kubeapi connectivity
kcfw_log cluster-info

# ------ Clean up prior runs ---------
log "Cleaning up $APP_NAME resources from prior runs."
# Disable retries and use || true because exit code 1 if spark application can't be found.
KUBECTL_ATTEMPTS_BACKUP=${KUBECTL_ATTEMPTS}
KUBECTL_ATTEMPTS=1
kcfw_log delete sparkapplication $APP_NAME || true
KUBECTL_ATTEMPTS=${KUBECTL_ATTEMPTS_BACKUP}

# kubectl returns success even if no pods match the label selector. But it seems you get an
# error if you match a pod and then that pod exits on its own at just the wrong time. Retry harmless in that case.
# Need || true anyway because grep to filter out the unwanted "No resources found." message will fail if no such message
# because there actually was something to delete.
kcfw_log delete pod -l $SELECTOR 2>&1 | grep -v "No resources" || true

# Wait for pods from prior runs to delete by looping until we get No resources result.
while ! $(kcfw_log get pod -l $SELECTOR 2>&1 | grep "No resources" > /dev/null); do sleep 1; done;

# ------ Run ---------
log "Creating SparkApplication $APP_NAME"
kcfw_log create -f $SPEC
SPARK_APP_START_TIME=$(epoch)

LAST_LOGGED=$(epoch)
log "Waiting for SparkApplication $APP_NAME to terminate."
STATE=$(state)
while ! $(echo ${STATE} | grep -P '(COMPLETED|FAILED)' > /dev/null); do
    EPOCH=$(epoch)
    # Use start time of script for timeout computation in order to still exit in timely fashion even if setup was slow
    if (( EPOCH - START_TIME >= TIMEOUT_SECS )); then
        log "Timeout reached. Aborting wait for SparkApplication $APP_NAME even though in non-terminal state $STATE."
        events;
        break
    fi
    if (( EPOCH - LAST_LOGGED > 180 )); then
        log "...still waiting for terminal state (currently $STATE) after $((EPOCH-SPARK_APP_START_TIME)) seconds. SparkApplication $APP_NAME Events so far:";
        events;
        LAST_LOGGED=${EPOCH}
    fi;
    report_pod_changes
    sleep 1;
    STATE=$(state)
done;
report_pod_changes # Report final status of spawned pods

# ------ Report Results ---------
END_TIME=$(epoch)
ELAPSED_SECS=$(($END_TIME - $SPARK_APP_START_TIME))
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

log -------- Executor Pods ----------
EXECUTORPODS = $(kcfw get pod -l ${SELECTOR},spark-role=executor -o name)
for POD_NAME in ${EXECUTORPODS}; do
    log ---- Begin $POD_NAME Log ----
    kcfw logs $POD_NAME || true
    log ---- End $POD_NAME Log ----
done;

# Alternatively, generate a Splunk link? Not sure there's a good way to filter for this particular execution, since the driver pod
# has the same name on every invocation on every fleet.

log "Completion of $APP_NAME test, returning $EXIT_CODE"
exit $EXIT_CODE
