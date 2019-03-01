#!/usr/bin/bash
set -o nounset
set -o errexit
set -o pipefail

# Disable use of SAM's custom kubeconfig
unset KUBECONFIG

kc() {
  kubectl -n flowsnake-watchdog "$@"
}

APP_NAME="watchdog-spark-operator"
SELECTOR="sparkoperator.k8s.io/app-name=$APP_NAME"

echo "Cleaning up $APP_NAME resources from prior runs"
kc delete sparkapplication $APP_NAME || true
kc delete pod -l $SELECTOR || true
# Wait for pods from prior runs to delete.
while ! $(kc get pod -l $SELECTOR 2>&1 | grep "No resources" > /dev/null); do sleep 1; done;

echo "Creating SparkApplication $APP_NAME"
kc create -f /watchdog-spark-operator/spark-application.json

echo "Waiting for SparkApplication $APP_NAME to complete"
# Terminal values are COMPLETED and FAILED https://github.com/GoogleCloudPlatform/spark-on-k8s-operator/blob/master/docs/design.md#the-crd-controller
while ! $(kc get sparkapplication $APP_NAME -o jsonpath='{.status.applicationState.state}' | grep -P '(COMPLETED|FAILED)' > /dev/null); do sleep 1; done;
echo "Terminal SparkApplication $APP_NAME state is $(kc get sparkapplication $APP_NAME -o jsonpath='{.status.applicationState.state}')"
# Test successful iff final state is COMPLETED. Use exit code from grep.
kc get sparkapplication $APP_NAME -o jsonpath='{.status.applicationState.state}' | grep COMPLETED > /dev/null
