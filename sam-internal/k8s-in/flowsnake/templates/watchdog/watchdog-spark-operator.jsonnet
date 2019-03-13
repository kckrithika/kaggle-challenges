local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local configs = import "config.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local watchdog = import "watchdog.jsonnet";
local estate = std.extVar("estate");

if !watchdog.watchdog_enabled then
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
                name: "watchdog-spark-operator-serviceaccount",
                namespace: "flowsnake",
            },
            automountServiceAccountToken: true,
        },
        # RoleBinding to grant the watchdog service account permission to create SparkApplications in flowsnake-watchdog namespace
        {
            kind: "RoleBinding",
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                name: "watchdog-spark-operator-rolebinding",
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
                    name: "watchdog-spark-operator-serviceaccount",
                    namespace: "flowsnake",
                }
            ]
        },
    ] + (if std.objectHas(flowsnake_images.feature_flags, "watchdog_canary_redo") then
    # ConfigMap containing the resources of the watchdog
    [
        {
            kind: "ConfigMap",
            apiVersion: "v1",
            metadata: {
                name: "watchdog-spark-on-k8s-spec-configmap",
                namespace: "flowsnake",
            },
            data: {
                "watchdog-spark-operator.json": std.toString(import "spark-on-k8s-canary-specs/watchdog-spark-operator.libsonnet"),
            } + if std.objectHas(flowsnake_images.feature_flags, "watchdog_canary_spark_s3") then
            {
                "watchdog-spark-s3.json": std.toString(import "spark-on-k8s-canary-specs/watchdog-spark-s3.libsonnet"), 
            } else {},
        },
        # ConfigMap containing the logic of the watchdog
        {
            kind: "ConfigMap",
            apiVersion: "v1",
            metadata: {
                name: "watchdog-spark-on-k8s-script-configmap",
                namespace: "flowsnake",
            },
            data: {
                "check-spark-operator.sh": importstr "spark-on-k8s-canary-scripts/watchdog-spark-on-k8s.sh"
            }
        }
    ] else 
    [
        # ConfigMap containing the logic and resources of the watchdog
        {
            kind: "ConfigMap",
            apiVersion: "v1",
            metadata: {
              name: "watchdog-spark-operator-configmap",
              namespace: "flowsnake",
            },
            data: {
                  "check-spark-operator.sh": importstr "watchdog-spark-operator--check-spark-operator.sh",
                  "spark-application.json": std.toString({
                        "apiVersion": "sparkoperator.k8s.io/v1beta1",
                        "kind": "SparkApplication",
                        "metadata": {
                            "name": "watchdog-spark-operator",
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
                            },
                            "executor": {
                                "cores": 1,
                                "instances": 1,
                                "labels": {
                                    "version": "2.4.0"
                                },
                                "memory": "512m",
                            },
                            "image": flowsnake_images.watchdog_spark_operator,
                            "imagePullPolicy": "Always",
                            "mainApplicationFile": "local:///spark-app/sample-spark-operator.jar",
                            "mainClass": "org.apache.spark.examples.SparkPi",
                            "mode": "cluster",
                            "restartPolicy": {
                                "type": "Never"
                            },
                            "sparkVersion": "",
                            "type": "Scala",
                        },
                  })
            }
        },
    ]) +
    [
        configs.deploymentBase("flowsnake") {
            local label_node = self.spec.template.metadata.labels,
            metadata: {
                labels: {
                    name: "watchdog-spark-operator",
                },
                name: "watchdog-spark-operator",
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
                                ] + (if std.objectHas(flowsnake_images.feature_flags, "watchdog_canary_redo") then
                                    [
                                        {
                                            mountPath: "/watchdog-spark-scripts",
                                            name: "watchdog-spark-scripts",
                                        },
                                        {
                                            mountPath: "/watchdog-spark-specs",
                                            name: "watchdog-spark-specs",
                                        },
                                    ]
                                else 
                                    [
                                        {
                                            mountPath: "/watchdog-spark-operator",
                                            name: "watchdog-spark-operator",
                                        },
                                    ]
                                ),
                            },
                        ],
                        serviceAccount: "watchdog-spark-operator-serviceaccount",
                        serviceAccountName: "watchdog-spark-operator-serviceaccount",
                        volumes: [
                            configs.config_volume("watchdog"),
                        ] + (if std.objectHas(flowsnake_images.feature_flags, "watchdog_canary_redo") then
                              [
                                  {
                                      configMap: {
                                          name: "watchdog-spark-on-k8s-spec-configmap",
                                      },
                                      name: "watchdog-spark-specs",
                                  },
                                  {
                                      configMap: {
                                          name: "watchdog-spark-on-k8s-script-configmap",
                                          # rw-r--r-- 644 octal, 420 decimal
                                          defaultMode: 420,
                                      },
                                      name: "watchdog-spark-scripts",
                                  },
                              ]
                        else  [
                            {
                                configMap: {
                                    name: "watchdog-spark-operator-configmap",
                                    # rw-r--r-- 644 octal, 420 decimal
                                    defaultMode: 420,
                                    items: [
                                        {
                                            key: "spark-application.json",
                                            path: "spark-application.json",
                                        },
                                        {
                                            key: "check-spark-operator.sh",
                                            path: "check-spark-operator.sh",
                                            # rwx-r-xr-x 755 octal, 493 decimal
                                            mode: 493,
                                        },
                                    ],
                                },
                                name: "watchdog-spark-operator",
                            },
                        ]) + [
                            watchdog.sfdchosts_volume 
                        ] 
                    },
                }
            }
        }
    ]
}
