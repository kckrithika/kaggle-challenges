#!/usr/bin/bash
set -o nounset
set -o errexit
set -o pipefail

# Disable use of SAM's custom kubeconfig, restore default Kubernetes behavior (this cluster's kubeapi using service account token)
unset KUBECONFIG

NAMESPACE=flowsnake-watchdog
KUBECTL_TIMEOUT_SECS=10
# Give kubeapi 1 minute to recover. 10 second timeout, 7th request begins 60s after 1st.
KUBECTL_ATTEMPTS=7

# default test timeout minutes
TIMEOUT_MINS=5

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
    --timeout-mins)
    # Specify a longer timeout for long running integration test (default is 5)
    export TIMEOUT_MINS="$2"
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

TEST_RUNNER_ID=${TEST_RUNNER_ID:-$(cut -c1-8 < /proc/sys/kernel/random/uuid)}

# Check if spec is a jsonnet template
if [[ ".jsonnet" == "${1: -8}" ]] ; then
    SPEC_INPUT=$(basename "$1")
    # Replace .jsonnet with -<ID>.json to get output filename
    SPEC_PATH=/strata-test-specs-out/${SPEC_INPUT%%.*}-${TEST_RUNNER_ID}.json
    jsonnet -V imageRegistry=${DOCKER_REGISTRY} -V jenkinsId=${TEST_RUNNER_ID} -V dockerTag=${DOCKER_TAG} -V s3ProxyHost=${S3_PROXY_HOST} -V driverServiceAccount=${DRIVER_SERVICE_ACCOUNT} -V kingdom=${KINGDOM} -V estate=${ESTATE} ${1} | \
    python -c 'import json,sys; j=json.load(sys.stdin); j_clean=j if len(j.keys())>1 else j[j.keys()[0]]; print json.dumps(j_clean, indent=4)' > ${SPEC_PATH}
    if [ -f "${SPEC_PATH}" ]; then
        SPEC="${SPEC_PATH}"
    else
        echo "spec ${SPEC_PATH} doesn't exist."
        exit 1
    fi
else
    # regular spec
    SPEC=$1
fi

APP_NAME=$(python -c 'import json,sys; print json.load(sys.stdin)["metadata"]["name"]' < $SPEC)
SELECTOR="sparkoperator.k8s.io/app-name=$APP_NAME"
# Exit after 5 minutes to ensure we exit before cliChecker kills us (10 mins) so that all output can be logged.
TIMEOUT_SECS=$((60*$TIMEOUT_MINS))

# output Unix time to stdout
epoch() {
    date '+%s'
}
START_TIME=$(epoch)

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

# Format (with heading marker) and output provided string to stdout
log_heading() {
    log "======== $@ ========"
}

# Format (with sub-heading marker) and output provided string to stdout
log_sub_heading() {
    log "---- $@ ----"
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
        # In addition to the timeout for this specific kubectl command, we need to check that the script hasn't
        # passed its overall timeout.
        EPOCH=$(epoch)
        stdout=$(mktemp /tmp/$(basename $0)-stdout.XXXXXX)
        stderr=$(mktemp /tmp/$(basename $0)-stderr.XXXXXX)
        # Capture result code, don't trigger errexit. https://stackoverflow.com/a/15844901
        timeout --signal=9 ${KUBECTL_TIMEOUT_SECS} kubectl -n ${NAMESPACE} "$@" 2>${stderr} >${stdout} && RESULT=$? || RESULT=$?
        # Hack to simplify scripting: if you try to delete something and get back a NotFound, treat that as a success.
        if [[ $(echo "$@" | grep -P '\bdelete\b') && $(grep -P '\(NotFound\).* not found' ${stderr}) ]]; then
            return 0
        fi
        # Hack to simplify scripting: 'No resources found' is never useful.
        # Goofy: get with a selector says "No resources found." on stderr but delete says "No resources found" on stdout.
        sed -i '/^No resources found\.\?$/d' ${stdout}
        sed -i '/^No resources found\.\?$/d' ${stderr}
        # Format captured stderr for logging and output it to stderr
        cat ${stderr} | format >&2
        rm ${stderr}
        cat ${stdout}
        rm ${stdout}
        if [[ $RESULT == 0 ]]; then
            # Success! We're done.
            return $RESULT;
        fi;
        MSG="Invocation ($ATTEMPT/$KUBECTL_ATTEMPTS) of [kubectl -n ${NAMESPACE} $@] failed ($(if (( $RESULT == 124 || $RESULT == 137 )); then echo "timed out (${KUBECTL_TIMEOUT_SECS}s)"; else echo $RESULT; fi))."
        if (( EPOCH - START_TIME >= TIMEOUT_SECS )); then
            log "$MSG Out of time. Giving up." >&2
            return ${RESULT}
        elif (( $ATTEMPT < $KUBECTL_ATTEMPTS )); then
            log "$MSG Will sleep $KUBECTL_TIMEOUT_SECS seconds and then try again." >&2
            sleep ${KUBECTL_TIMEOUT_SECS}
        else
            log "$MSG Giving up." >&2
            return ${RESULT}
        fi;
        ATTEMPT=$(($ATTEMPT + 1))
    done;
}

# Like kcfw, plus also apply log formatting to stdout.
kcfw_log() {
  # pipefail is set, so sed won't lose any failure exit code returned by kubectl
  # stderr is already formatted by kcfw, so only need to add formatting to stdout
  kcfw "$@" | format
}

# Extract the "Events" section from a kubectl description of a resource.
events() {
    log_sub_heading "Begin Events"
    # awk magic prints only the Name: line and the Events lines (terminated by a blank line).
    # Use kcfw and explicitly call format after so Awk can look for start-of-line.
    kcfw describe sparkapplication $APP_NAME | awk '/Events:/{flag=1}/^$/{flag=0}(flag||/^Name:/)' | format
    kcfw describe pod -l ${SELECTOR},spark-role=driver | awk '/Events:/{flag=1}/^$/{flag=0}(flag||/^Name:/)' | format
    kcfw describe pod -l ${SELECTOR},spark-role=executor | awk '/Events:/{flag=1}/^$/{flag=0}(flag||/^Name:/)' | format
    log_sub_heading "End Events"
}

# Return the state of the Spark application.
# Terminal values are COMPLETED and FAILED https://github.com/GoogleCloudPlatform/spark-on-k8s-operator/blob/master/docs/design.md#the-crd-controller
state() {
    kcfw get sparkapplication $APP_NAME -o jsonpath='{.status.applicationState.state}'
}

# Output logs for specified pod to stdout
# Future: Alternatively, generate a Splunk link?
declare -A POD_LOGS_COLLECTED # pod name -> "true" if logs for pod were already collected
pod_log() {
    # Checking for key with set -o nounset active: https://stackoverflow.com/a/13221491
    if [[ -z "${POD_LOGS_COLLECTED[$1]+present}" ]]; then
        log_sub_heading "Begin $1 madkub-init Log"
        # || true to avoid failing script if pod has gone away.
        KUBECTL_ATTEMPTS_SAVE=$KUBECTL_ATTEMPTS
        KUBECTL_ATTEMPTS=1
        kcfw logs -c madkub-init $1 || true
        log_sub_heading "End $1 madkub-init Log"
        CONTAINER_NAME=""
        for CONTAINER_NAME in $(kcfw get $1 -o jsonpath='{.spec.containers[*].name}'); do
            log_sub_heading "Begin container $CONTAINER_NAME Log in pod $1"
            # || true to avoid failing script if pod has gone away.
            kcfw logs -c $CONTAINER_NAME $1 || true
            log_sub_heading "End container $CONTAINER_NAME Log"
        done;
        KUBECTL_ATTEMPTS=$KUBECTL_ATTEMPTS_SAVE
        POD_LOGS_COLLECTED["$1"]="true"
    fi
}

# Log changes to pods spawned for SparkApplication
declare -A PREVIOUS_POD_REPORTS # pod name -> "<pod_status> on host <nodeName>"
report_pod_changes() {
    unset POD_REPORTS
    declare -A POD_REPORTS # pod name -> "<pod_status> on host <nodeName>"
    # Fetch pod names and their status for this SparkApplication
    # Note that the status from kubectl get contains a more informative single-term status than is available in the JSON.
    # The JSON contains the phase (Pending -> Running -> Completed), which does not mention Init, and the detailed
    # conditions and containerStatuses lists, which are difficult to summarize.
    # Relevant pods for our spark application have label metadata.labels.spark-app-selector=$APP_ID
    # Reading command output line by line: https://unix.stackexchange.com/a/52027
    while read POD_REPORT; do
        POD_NAME=$(echo $POD_REPORT | cut -d' ' -f1)
        REPORT=$(echo $POD_REPORT | cut -d' ' -f1 --complement)
        POD_REPORTS["$POD_NAME"]="${REPORT}"
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
        # The hostname won't change, so only report the pod status. ${VAR%% *} means delete everything after the first
        # space. Thus "<pod_status> on host <nodeName>" becomes "<pod_status>"
        # http://tldp.org/LDP/abs/html/string-manipulation.html
        # Except if the previous status was 'Pending on host <none>', in which case this is the first opportunity to log
        # the host name.
        OLD_REPORT="${PREVIOUS_POD_REPORTS[${POD_NAME}]}"
        NEW_REPORT="${POD_REPORTS[${POD_NAME}]}"
        if [[ "${OLD_REPORT}" != "${NEW_REPORT}" ]]; then
            if [[ ${OLD_REPORT} == *"on host <none>" ]] && [[ ${NEW_REPORT} != *"on host <none>" ]]; then
                REPORT_DISPLAY="${NEW_REPORT}"
            else
                REPORT_DISPLAY="${NEW_REPORT%% *}"
            fi
            log "Pod change detected: ${POD_NAME} changed to ${REPORT_DISPLAY} (previously ${OLD_REPORT%% *})."
            PREVIOUS_POD_REPORTS["$POD_NAME"]="${NEW_REPORT}"
            if [[ "${NEW_REPORT%% *}" == "Completed" ]] || [[ "${NEW_REPORT%% *}" == "Error" ]] || [[ "${NEW_REPORT%% *}" == "Terminating" ]]; then
                # Grab the logs now rather than waiting until the end of the script; the pod might be deleted by then.
                pod_log po/${POD_NAME}
            fi
        fi
    done;
}


# ------ Initialize ---------
log_heading "Beginning $APP_NAME test"
# Sanity-check kubeapi connectivity
kcfw_log cluster-info

# ------ Clean up prior runs ---------
log "Cleaning up SparkApplication/Pod older than 1 hours from prior runs."
# https://stackoverflow.com/questions/48934491/kubernetes-how-to-delete-pods-based-on-age-creation-time
APPS=$(kcfw get sparkapplication -o go-template='{{range .items}}{{.metadata.name}} {{.metadata.creationTimestamp}}{{"\n"}}{{end}}' | awk '$2 <= "'$(date -d'now-1 hours' -Ins --utc | sed 's/+0000/Z/')'" { print $1 }')
for APP in ${APPS}; do
    PODSELECTOR="sparkoperator.k8s.io/app-name=${APP}"
    kcfw_log delete sparkapplication ${APP}
    kcfw_log delete pod -l ${PODSELECTOR}
done

# ------ Run ---------
log "Creating SparkApplication $APP_NAME"
kcfw_log create -f $SPEC
SPARK_APP_START_TIME=$(epoch)

# If we've gotten this far, we'd like to collect as much forensic data as possible
set +o errexit

LAST_LOGGED=$(epoch)
log "Waiting for SparkApplication $APP_NAME to reach a terminal state."
STATE=$(state)
while true; do
    EPOCH=$(epoch)
    if $(echo ${STATE} | grep -P '(COMPLETED|FAILED)' > /dev/null); then
        log "SparkApplication $APP_NAME has terminated after $(($EPOCH - $SPARK_APP_START_TIME)) seconds. State is $STATE."
        break
    fi
    # Use start time of script for timeout computation in order to still exit in timely fashion even if setup was slow
    if (( EPOCH - START_TIME >= TIMEOUT_SECS )); then
        log "Timeout reached. Aborting wait for SparkApplication $APP_NAME even though in non-terminal state $STATE."
        break
    fi
    if (( EPOCH - LAST_LOGGED > 60 )); then
        log "...still waiting for terminal state (currently $STATE) after $((EPOCH-SPARK_APP_START_TIME)) seconds.";
        events;
        LAST_LOGGED=${EPOCH}
    fi;
    sleep 1;
    report_pod_changes
    STATE=$(state)
done;
EXIT_CODE=$(echo ${STATE} | grep COMPLETED > /dev/null; echo $?)

# ------ Report Results ---------
report_pod_changes
events

POD_NAME=$(kcfw get pod -l ${SELECTOR},spark-role=driver -o name)
if [[ -z ${POD_NAME} ]]; then
    log "Cannot locate driver pod. Maybe it never started? No logs to display."
else
    pod_log ${POD_NAME}
fi

log -------- Executor Pods ----------
EXECUTOR_PODS=$(kcfw get pod -l ${SELECTOR},spark-role=executor -o name)
for POD_NAME in ${EXECUTOR_PODS}; do
    pod_log ${POD_NAME}
done;

if $(echo ${STATE} | grep -P '(COMPLETED|FAILED)' > /dev/null); then
    # Delete so that Kubernetes is in a cleaner state when the next test execution starts
    log "Cleaning up stuff for completed or failed test."
    kcfw_log delete sparkapplication ${APP_NAME}
    kcfw_log delete pod -l ${SELECTOR}
fi

log_heading "Completion of $APP_NAME test, returning $EXIT_CODE"
exit ${EXIT_CODE}
