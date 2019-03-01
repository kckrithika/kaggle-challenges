#!/usr/bin/bash
set -o nounset
set -o errexit
set -o pipefail

# Disable use of SAM's custom kubeconfig
unset KUBECONFIG

kc() {
  kubectl -n flowsnake-watchdog "$@"
}

echo "Cleaning up resources from prior runs"
kc delete sparkapplication lorrin-spark-pi || true
kc delete pod -l sparkoperator.k8s.io/launched-by-spark-operator=true || true
# Wait for pods from prior runs to delete.
while ! $(kc get pod -l sparkoperator.k8s.io/launched-by-spark-operator=true 2>&1 | grep "No resources" > /dev/null); do sleep 1; done;

echo "Creating SparkApplication"
kc create -f /config/operator-test.yaml

echo "Waiting for SparkApplication to complete"
# Terminal values are COMPLETED and FAILED https://github.com/GoogleCloudPlatform/spark-on-k8s-operator/blob/master/docs/design.md#the-crd-controller
while ! $(kc get sparkapplication lorrin-spark-pi -o jsonpath='{.status.applicationState.state}' | grep -P '(COMPLETED|FAILED)' > /dev/null); do sleep 1; done;
echo "Terminal SparkApplication state is $(kc get sparkapplication lorrin-spark-pi -o jsonpath='{.status.applicationState.state}')"
# Test successful iff final state is COMPLETED. Use exit code from grep.
kc get sparkapplication lorrin-spark-pi -o jsonpath='{.status.applicationState.state}' | grep COMPLETED > /dev/null
