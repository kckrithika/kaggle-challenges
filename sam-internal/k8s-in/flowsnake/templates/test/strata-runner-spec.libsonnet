
# This is the spec used by integration test runner pods, the special case of the cliChecker
# container that runs integration tests for Strata builds. It is not created directly; rather,
# the integration test runner agent submits them to k8s in response to requests from Strata.
#
# Note:  The following strings will be substituted by the agent before submission to k8s:
#  {{TAG}} = the tag of the images to test
#  {{NAME}} = the name of this runner pod

local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnake_config = import "flowsnake_config.jsonnet";
local kingdom = std.extVar("kingdom");
local estate = std.extVar("estate");
local runner_image = flowsnake_config.strata_registry  + "/flowsnake-spark-on-k8s-integration-test-runner";

{
    kind: "Pod",
    apiVersion: "v1",
    metadata: {
        name: "{{NAME}}",
        namespace: "flowsnake-ci-tests",
        annotations: {
            "sfdc.net/itest-tag": "{{TAG}}",
            "sfdc.net/pki-client-name-suffix": "flowsnake-ci-test", # read by madkub injector
        },
        labels: {
            app: "flowsnake-strata-test-runner",
            apptype: "testing",
            flowsnakeOwner: "dva-transform",
            flowsnakeRole: "StrataTestRunner",
        },
    },
    spec: {
        restartPolicy: "Never",
        hostNetwork: false,
        serviceAccountName: "spark-driver-flowsnake-ci-tests",  # driver SA ~~ client SA
        volumes: [
            {
                configMap: {
                    name: "strata-test-spark-on-k8s-script-configmap",
                    # rwxr-xr-x 755 octal, 493 decimal
                    defaultMode: 493,
                },
                name: "watchdog-spark-scripts",
            },
        ],
        initContainers: [],
        containers: [
            # No MadKub refresher container; job expected to complete w/in 24hr.
            {
                image: runner_image + ":{{TAG}}",
                imagePullPolicy: "Always",
                name: "{{NAME}}",
                command: ["/bin/sh", "-c", "/scripts/runalltests.sh"],
                env: [
                    { name: "DOCKER_TAG", value: "{{TAG}}" },
                    { name: "TEST_RUNNER_ID", value: "{{NAME}}" },
                    { name: "S3_PROXY_HOST", value: flowsnake_config.s3_public_proxy_host },
                    { name: "DRIVER_SERVICE_ACCOUNT", value: "spark-driver-flowsnake-ci-tests" },
                    { name: "DOCKER_REGISTRY", value: flowsnake_config.registry },
                    { name: "KINGDOM", value: kingdom },
                    { name: "ESTATE", value: estate }
                ],
                securityContext: {
                    runAsUser: 0,   # root
                },
                resources: {
                    requests: {
                        cpu: "1",
                        memory: "500Mi",
                    },
                    limits: {
                        cpu: "1",
                        memory: "500Mi",
                    },
                },
                volumeMounts: [
                    {
                        mountPath: "/watchdog-spark-scripts",
                        name: "watchdog-spark-scripts",
                        readOnly: true,
                    }
                ],
            }
        ],
    }
}
