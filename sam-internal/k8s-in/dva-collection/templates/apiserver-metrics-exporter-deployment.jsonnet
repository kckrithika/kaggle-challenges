local configs = import "config.jsonnet";

local collectionUtils = import "collection-agent-utils.jsonnet";

local funnelEndpointHost = std.split(configs.funnelVIP, ":")[0];
local funnelEndpointPort = std.split(configs.funnelVIP, ":")[1];

local volumes = [
    {
        name: "opencensus-conf-tpl",
        configMap: {
            name: collectionUtils.apiserver.configMapName,
        },
    },
    {
        name: "opencensus-conf-gen",
        emptyDir: {},
    },
];


local initVolumeMounts = [
    {
        mountPath: "/templates",
        name: "opencensus-conf-tpl",
    },
    {
        mountPath: "/generated",
        name: "opencensus-conf-gen",
    },
];

local volumeMounts = [
    {
        mountPath: "/config",
        name: "opencensus-conf-gen",
    },
];

if collectionUtils.apiserver.featureFlag then {
    apiVersion: "apps/v1beta1",
    kind: "Deployment",
    metadata: {
        name: collectionUtils.apiserver.name,
        namespace: collectionUtils.apiserver.namespace,
        labels: {
            app: collectionUtils.apiserver.name,
        },
    },
    spec: {
        selector: {
            matchLabels: {
                app: collectionUtils.apiserver.name,
            },
        },
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    app: collectionUtils.apiserver.name,
                },
            },
            spec: {
                serviceAccountName: collectionUtils.apiserver.name,
                automountServiceAccountToken: true,
                volumes+: []
                    + volumes,
                initContainers: [
                    {
                        name: "prom-to-argus-init",
                        image: collectionUtils.apiserver.configGenImage,
                        imagePullPolicy: "Always",
                        env: [
                            {
                                name: "KINGDOM",
                                value: configs.kingdom,
                            },
                            {
                                name: "ESTATE",
                                value: configs.estate,
                            },
                            {
                                name: "SUPERPOD",
                                value: "-",
                            },
                            {
                                name: "POD",
                                value: "-",
                            },
                            {
                                name: "FUNCTION_INSTANCE_NAME",
                                valueFrom:
                                {
                                    fieldRef: { fieldPath: "metadata.name", apiVersion: "v1" },
                                },
                            },
                            {
                                name: "SFDC_METRICS_SERVICE_HOST",
                                value: funnelEndpointHost,
                            },
                            {
                                name: "SFDC_METRICS_SERVICE_PORT",
                                value: funnelEndpointPort,
                            },
                        ],
                        command: [
                            "/app/config_gen.rb",
                            "-t",
                            "/templates/opencensus.cluster-metrics-exporter.yaml.erb",
                            "-o",
                            "/generated/opencensus.yaml",
                        ],
                        volumeMounts: initVolumeMounts,
                    },
                ],
                containers: [
                    # Dummy sidecar to force Image promotion for the initContainer Image.
                    # Currently, only Images used in containers are promomoted.
                    # W-6651242 is the story for the fix.
                    {
                        name: "dummy-image-promoter",
                        image: collectionUtils.apiserver.configGenImage,
                        imagePullPolicy: "Always",
                        command: [
                            "sleep",
                            "infinity",
                        ],
                    },
                    {
                        name: "prom-to-argus",
                        image: collectionUtils.apiserver.opencensusImage,
                        imagePullPolicy: "Always",
                        command: [
                            "ocagent",
                            "--config=/config/opencensus.yaml",
                        ],

                        livenessProbe: {
                        httpGet: {
                            path: "/debug/rpcz",
                            port: 55679,
                        },
                        initialDelaySeconds: 15,
                        periodSeconds: 120,
                        },
                        resources: {
                            requests: {
                                memory: "100Mi",
                                cpu: "150m",
                            },
                            limits: {
                                cpu: "300m",
                            },
                        },
                        volumeMounts: volumeMounts,
                    },
                ],
                # Ensure scheduling in the same pool as the master/apiserver nodes so that they are reachable.
                # Master nodes in prd-sam do not have the "pool=<estate> label,
                # so this will only schedule on compute which should be satisfactory.
                # Everywhere else this includes master + compute nodes.
                nodeSelector: {
                    pool: configs.estate,
                },
            },
        },
    },
} else "SKIP"
