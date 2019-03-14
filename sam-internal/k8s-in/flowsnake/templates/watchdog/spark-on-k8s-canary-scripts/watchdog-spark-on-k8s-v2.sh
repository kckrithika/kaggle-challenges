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

SPEC=$1
APP_NAME=$(python -c 'import json,sys; print json.load(sys.stdin)["metadata"]["name"]' < $SPEC)
SELECTOR="sparkoperator.k8s.io/app-name=$APP_NAME"

echo "Cleaning up $APP_NAME resources from prior runs"
# || true because exit code 1 if spark application can't be found.
kcfw delete sparkapplication $APP_NAME || true
# kubectl returns success even if no pods match the label selector. This is helpful,
# this will have the side-effect of aborting the script early if it cannot access kubeapi.
kcfw delete pod -l $SELECTOR
# Wait for pods from prior runs to delete.
while ! $(kcfw get pod -l $SELECTOR 2>&1 | grep "No resources" > /dev/null); do sleep 1; done;

echo "Creating SparkApplication $APP_NAME"
kcfw create -f $SPEC

echo "Waiting for SparkApplication $APP_NAME to complete"
# Terminal values are COMPLETED and FAILED https://github.com/GoogleCloudPlatform/spark-on-k8s-operator/blob/master/docs/design.md#the-crd-controller
while ! $(kcfw get sparkapplication $APP_NAME -o jsonpath='{.status.applicationState.state}' | grep -P '(COMPLETED|FAILED)' > /dev/null); do sleep 1; done;
echo ---- Begin Spark Driver Log ----
kcfw logs $(kcfw get pod -l $SELECTOR -o name) || true
echo ---- End Spark Driver Log ----
echo "Terminal SparkApplication $APP_NAME state is $(kcfw get sparkapplication $APP_NAME -o jsonpath='{.status.applicationState.state}')"
# Test successful iff final state is COMPLETED. Use exit code from grep.
kcfw get sparkapplication $APP_NAME -o jsonpath='{.status.applicationState.state}' | grep COMPLETED > /dev/null
