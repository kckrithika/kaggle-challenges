
local flowsnake_config = import "flowsnake_config.jsonnet";
local watchdog = import "watchdog.jsonnet";
local flowsnake_images = import "flowsnake_images.jsonnet";

# This is the configmap(s) containing test-runner scripts used by the
# watchdogs and the build system integration tests.  To add a new script, add
# it to the configmap_data map immediately below.  To deploy the scripts in a new
# namespace, add an item to the list of configmap specs with the new name and namespace.

local configmap_data =
    (if std.objectHas(flowsnake_images.feature_flags, "interaction_test_script_change") then
        {"check-spark-operator.sh": importstr "spark-on-k8s-canary-scripts/watchdog-spark-on-k8s-tmp.sh",} 
    else if std.objectHas(flowsnake_images.feature_flags, "spark_operator_watchdog_parallel_run") then
        {"check-spark-operator.sh": importstr "spark-on-k8s-canary-scripts/watchdog-spark-on-k8s-test.sh",}
    else
        {"check-spark-operator.sh": importstr "spark-on-k8s-canary-scripts/watchdog-spark-on-k8s.sh",})
    +{
        "check-impersonation.sh": importstr "spark-on-k8s-canary-scripts/check-impersonation.sh",
        "kubeconfig-impersonation-proxy": std.toString(import "spark-on-k8s-canary-scripts/kubeconfig-impersonation-proxy.libsonnet"),
    };

(if watchdog.watchdog_enabled then [
    {
        kind: "ConfigMap",
        apiVersion: "v1",
        metadata: {
            name: "watchdog-spark-on-k8s-script-configmap",
            namespace: "flowsnake",
        },
        data: configmap_data,
    }
] else [] )
+ (if flowsnake_config.ci_resources_enabled then [
    {
        kind: "ConfigMap",
        apiVersion: "v1",
        metadata: {
            name: "strata-test-spark-on-k8s-script-configmap",
            namespace: "flowsnake-ci-tests",
        },
        data: configmap_data,
    }
] else [] )
