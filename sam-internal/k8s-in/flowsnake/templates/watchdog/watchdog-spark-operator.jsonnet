local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local configs = import "config.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local madkub_common = import "madkub_common.jsonnet";
local watchdog = import "watchdog.jsonnet";
local enabled_canary_versions = [ ver for ver in watchdog.watchdog_canary_versions if std.objectHas(flowsnake_images.version_mapping.main, ver)];
local cert_name = "watchdogcanarycerts";

if ! watchdog.watchdog_enabled || ! std.objectHas(flowsnake_images.feature_flags, "spark_op_watchdog") then
"SKIP"
else
{
    apiVersion: "v1",
    kind: "List",
    metadata: {},
    items: [
        # Service account in the Flowsnake namespace used for the watchdog itself
        {
            kind: "ServiceAccount",
            apiVersion: "v1",
            metadata: {
                name: "watchdog-spark-operator",
                namespace: "flowsnake",
            },
            automountServiceAccountToken: true,
        },
        # RoleBinding to grant the watchdog service account permission to create SparkApplications in flowsnake-watchdog namespace
        {
            kind: "RoleBinding",
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                name: "watchdog-spark-operator-RoleBinding",
                namespace: "flowsnake-watchdog",
                annotations: {
                    "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            roleRef: {
                kind: "Role",
                name: "flowsnake-client-flowsnake-watchdog-Role",
                apiGroup: "rbac.authorization.k8s.io",
            },
            subjects: [
                {
                    kind: "ServiceAccount",
                    name: "watchdog-spark-operator",
                    namespace: "flowsnake",
                }
            ]
        },
        # ConfigMap containing the logic and resources of the watchdog
        {
            kind: "ConfigMap",
            apiVersion: "v1",
            metadata: {
              name: "watchdog-spark-operator-ConfigMap",
              namespace: "flowsnake",
            },
            data: {
                "check-spark-operator.sh": (importstr "watchdog-spark-operator--check-spark-operator.sh"),
                "spark-application.json": std.toString({
                    "apiVersion": "sparkoperator.k8s.io/v1beta1",
                    "kind": "SparkApplication",
                    "metadata": {
                        "name": "watchdog-spark-operator-app",
                        "namespace": "flowsnake-watchdog",
                    },
                    "spec": {
                        "deps": {},
                        "driver": {
                            "coreLimit": "200m",
                            "cores": 0.1,
                            "labels": {
                                "version": "2.4.0"
                            },
                            "memory": "512m",
                            "serviceAccount": "spark-driver-flowsnake-watchdog",
                            "volumeMounts": [
                                {
                                    "mountPath": "/tmp",
                                    "name": "test-volume"
                                }
                            ]
                        },
                        "executor": {
                            "cores": 1,
                            "instances": 1,
                            "labels": {
                                "version": "2.4.0"
                            },
                            "memory": "512m",
                            "volumeMounts": [
                                {
                                    "mountPath": "/tmp",
                                    "name": "test-volume"
                                }
                            ]
                        },
                        "image": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/lorrin.nelson/flowsnake-sample-spark-operator:20190219104328",
                        "imagePullPolicy": "Always",
                        "mainApplicationFile": "local:///tmp/spark-examples_2.11-2.4.0.jar",
                        "mainClass": "org.apache.spark.examples.SparkPi",
                        "mode": "cluster",
                        "restartPolicy": {
                            "type": "Never"
                        },
                        "sparkVersion": "",
                        "type": "Scala",
                        "volumes": [
                            {
                                "hostPath": {
                                    "path": "/tmp",
                                    "type": "Directory"
                                },
                                "name": "test-volume"
                            }
                        ]
                    },
                }),
            },
        },
        configs.deploymentBase("flowsnake") {
            local label_node = self.spec.template.metadata.labels,
            metadata: {
                labels: {
                    name: "watchdog-spark-operator",
                },
                name: "watchdog-spark-operator-Deployment",
                namespace: "flowsnake",
            },
            spec+: {
                selector: {
                    matchLabels: {
                        app: label_node.app,
                        apptype: label_node.apptype,
                    }
                },
                template: {
                    metadata: {
                        labels: {
                            app: "watchdog-spark-operator",
                            apptype: "monitoring",
                            flowsnakeOwner: "dva-transform",
                            flowsnakeRole: "WatchdogSparkOperator",
                        },
                    },
                    spec: {
                        restartPolicy: "Always",
                        hostNetwork: true,
                        containers: [
                            {
                                image: flowsnake_images.watchdog,
                                imagePullPolicy: flowsnakeconfig.default_image_pull_policy,
                                command: [
                                    "/sam/watchdog",
                                    "-role=CLI",
                                    "-emailFrequency=" + watchdog.watchdog_email_frequency,
                                    "-timeout=2s",
                                    "-funnelEndpoint=" + flowsnakeconfig.funnel_vip_and_port,
                                    "--config=/config/watchdog.json",
                                    "-cliCheckerCommandTarget=SparkOperatorTest",
                                    "--hostsConfigFile=/sfdchosts/hosts.json",
                                    "-watchdogFrequency=15m",
                                    "-alertThreshold=45m",
                                    "-cliCheckerTimeout=15m",
                                ],
                                name: "watchdog-canary",
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
                                    configs.config_volume_mount,
                                    watchdog.sfdchosts_volume_mount,
                                    {
                                        mountPath: "/watchdog-spark-operator",
                                        name: "watchdog-spark-operator",
                                    },
                                ],
                            },
                        ],
                        volumes: [
                            configs.config_volume("watchdog"),
                            {
                                configMap: {
                                    name: "watchdog-spark-operator-ConfigMap",
                                },
                                name: "watchdog-spark-operator",
                            },
                        ]
                          + [ watchdog.sfdchosts_volume ],
                    },
                }
            }
        }
    ]
}
