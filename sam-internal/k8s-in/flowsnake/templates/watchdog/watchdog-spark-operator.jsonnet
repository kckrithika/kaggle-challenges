local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local configs = import "config.jsonnet";
local kingdom = std.extVar("kingdom");
local estate = std.extVar("estate");
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
        }]
        + (import "watchdog-spark-operator-scripts.libsonnet")
        + [
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
                        # In PCL, Madkub server runs on flannel network and replies 403 (forbidden) to pod running on host network
                        hostNetwork: if flowsnakeconfig.is_public_cloud then false else true,
                        containers: [
                            {
                                image: flowsnake_images.spark_operator_watchdog_canary,
                                imagePullPolicy: flowsnakeconfig.default_image_pull_policy,
                                command: [
                                    "/sam/watchdog",
                                    "-role=CLI",
                                    # Dial down these emails until false positives reduced.
                                    # "-emailFrequency=" + watchdog.watchdog_email_frequency,
                                    "-emailFrequency=1h",
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
                                    "-cliCheckerTimeout=6m",
                                    "-includeCommandOutput=true",
                                ] + (if flowsnakeconfig.is_public_cloud then [
                                # In PCL, watchdog runs on flannel network and host name becomes pod name, so need to explicitly pass in kingdom
                                # and estate to tag metrics.
                                    "-kingdom="+kingdom,
                                    "-estate="+estate,
                                ] else []),
                                name: "watchdog",
                                # runtime: failed to create new OS thread (have 6 already; errno=12) means more RAM needed
                                # (see https://stackoverflow.com/questions/46484627/golang-runtime-failed-to-create-new-os-thread-have-2049-already-errno-12)
                                # Last seen with 500M and running 3 commands 2019-04-02.
                                resources: {
                                    requests: {
                                        cpu: "1",
                                        memory: "1Gi",
                                    },
                                    limits: {
                                        cpu: "1",
                                        memory: "1Gi",
                                    },
                                },
                                volumeMounts: [
                                    configs.config_volume_mount,
                                    watchdog.sfdchosts_volume_mount,
                                    {
                                        mountPath: "/watchdog-spark-scripts",
                                        name: "watchdog-spark-scripts",
                                    },
                                ]
                                 + madkub_common.cert_mounts(cert_name),
                                env: [
                                    { name: "DOCKER_TAG", value: flowsnake_images.per_phase[flowsnake_images.phase].image_tags.integration_test_tag },
                                    { name: "TEST_RUNNER_ID", value: "canary" },
                                    { name: "S3_PROXY_HOST", value: flowsnakeconfig.s3_public_proxy_host },
                                    { name: "DRIVER_SERVICE_ACCOUNT", value: "spark-driver-flowsnake-watchdog" },
                                ]+ (if std.objectHas(flowsnake_images.feature_flags, "fix_canary_registry") then
                                [ { name: "DOCKER_REGISTRY", value: flowsnakeconfig.registry }, ] else []),
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
                                    name: "watchdog-spark-on-k8s-script-configmap",
                                    # rwxr-xr-x 755 octal, 493 decimal
                                    defaultMode: 493,
                                },
                                name: "watchdog-spark-scripts",
                            },
                            watchdog.sfdchosts_volume
                        ]
                        + madkub_common.cert_volumes(cert_name),
                    },
                }
            }
        }
    ]
}
