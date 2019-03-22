local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local configs = import "config.jsonnet";
local kingdom = std.extVar("kingdom");
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local madkub_common = import "madkub_common.jsonnet";
local watchdog = import "watchdog.jsonnet";
local cert_name = "watchdogsparkoperator";
local std_new = import "stdlib_0.12.1.jsonnet";

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

        # ConfigMap containing the resources of the watchdog
        {
            kind: "ConfigMap",
            apiVersion: "v1",
            metadata: {
                name: "watchdog-spark-on-k8s-spec-configmap",
                namespace: "flowsnake",
            },
            data: {
                "watchdog-spark-operator.json": std.toString(import "spark-on-k8s-canary-specs/watchdog-spark-operator.libsonnet"),
                "watchdog-spark-impersonation.json": std.toString(import "spark-on-k8s-canary-specs/watchdog-spark-impersonation.libsonnet"),
                "kubeconfig-impersonation-proxy": std.toString(import "spark-on-k8s-canary-specs/kubeconfig-impersonation-proxy.libsonnet"),
            }
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
                "check-spark-operator.sh": importstr "spark-on-k8s-canary-scripts/watchdog-spark-on-k8s.sh",
                "check-impersonation.sh": importstr "spark-on-k8s-canary-scripts/check-impersonation.sh",
            }
        },
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
                        annotations: {
                            "madkub.sam.sfdc.net/allcerts": std.toString({
                                certreqs: [
                                    {
                                        name: cert_name,
                                        role: "flowsnake_test.flowsnake-watchdog",
                                        "cert-type": "client",
                                        kingdom: kingdom,
                                    }
                                ]
                            })
                        },
                        labels: {
                            app: "watchdog-spark-operator",
                            apptype: "monitoring",
                            flowsnakeOwner: "dva-transform",
                            flowsnakeRole: "WatchdogSparkOperator",
                        },
                    },
                    spec: {
                        # Watchdogs run as user sfdc (7337) per https://git.soma.salesforce.com/sam/sam/blob/master/docker/hypersam/Dockerfile
                        initContainers: [ madkub_common.init_container(cert_name, user=7337), ],
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
                                    # Delay between runs. We want to more or less run continuously.
                                    "-watchdogFrequency=1m",
                                    # Alert if last success was longer ago than this.
                                    "-alertThreshold=1m",
                                    # Kill and fail test if it runs for longer than this.
                                    "-cliCheckerTimeout=15m",
                                ],
                                name: "watchdog",
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
                                        mountPath: "/watchdog-spark-scripts",
                                        name: "watchdog-spark-scripts",
                                    },
                                    {
                                        mountPath: "/watchdog-spark-specs",
                                        name: "watchdog-spark-specs",
                                    },
                                ] + madkub_common.cert_mounts(cert_name),
                            },
                            # Watchdogs run as user sfdc (7337) per https://git.soma.salesforce.com/sam/sam/blob/master/docker/hypersam/Dockerfile
                            madkub_common.refresher_container(cert_name, user=7337)
                        ],
                        serviceAccount: "watchdog-spark-operator-serviceaccount",
                        serviceAccountName: "watchdog-spark-operator-serviceaccount",
                        volumes: [
                            configs.config_volume("watchdog"),
                            {
                                configMap: {
                                    name: "watchdog-spark-on-k8s-spec-configmap",
                                },
                                name: "watchdog-spark-specs",
                            },
                            {
                                configMap: {
                                    name: "watchdog-spark-on-k8s-script-configmap",
                                    # rwxr-xr-x 755 octal, 493 decimal
                                    defaultMode: 493,
                                },
                                name: "watchdog-spark-scripts",
                            },
                            watchdog.sfdchosts_volume
                        ] + madkub_common.cert_volumes(cert_name),
                    },
                }
            }
        }
    ]
}
