#!/usr/bin/bash
set -o nounset
set -o errexit
set -o pipefail

# Disable use of SAM's custom kubeconfig
unset KUBECONFIG

kcfw() {
  kubectl -n flowsnake-watchdog "$@"
}

# APP_NAME="watchdog-spark-operator"
APP_NAME=$2
SELECTOR="sparkoperator.k8s.io/app-name=$APP_NAME"

echo "Cleaning up $APP_NAME resources from prior runs"
kcfw delete sparkapplication $APP_NAME || true
kcfw delete pod -l $SELECTOR || true
# Wait for pods from prior runs to delete.
while ! $(kcfw get pod -l $SELECTOR 2>&1 | grep "No resources" > /dev/null); do sleep 1; done;

echo "Creating SparkApplication $APP_NAME"
kcfw create -f /watchdog-spark-operator/$1

echo "Waiting for SparkApplication $APP_NAME to complete"
# Terminal values are COMPLETED and FAILED https://github.com/GoogleCloudPlatform/spark-on-k8s-operator/blob/master/docs/design.md#the-crd-controller
while ! $(kcfw get sparkapplication $APP_NAME -o jsonpath='{.status.applicationState.state}' | grep -P '(COMPLETED|FAILED)' > /dev/null); do sleep 1; done;
echo "Terminal SparkApplication $APP_NAME state is $(kcfw get sparkapplication $APP_NAME -o jsonpath='{.status.applicationState.state}')"
# Test successful iff final state is COMPLETED. Use exit code from grep.
kcfw get sparkapplication $APP_NAME -o jsonpath='{.status.applicationState.state}' | grep COMPLETED > /dev/null
