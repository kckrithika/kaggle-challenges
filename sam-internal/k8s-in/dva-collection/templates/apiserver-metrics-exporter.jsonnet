local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

# Add your estates here
local featureFlag = (configs.estate == "prd-samtest");

local name = "apiserver-metrics-exporter";
local namespace = "sam-system";

local configMapName = "apiserver-metrics-exporter-cm";
local configTemplate = importstr "configs/ocagent/opencensus.apiserver-metrics-exporter.yaml.erb";

local funnelEndpointHost = std.split(configs.funnelVIP, ":")[0];
local funnelEndpointPort = std.split(configs.funnelVIP, ":")[1];

local configGenImage = "%s/dva/collection-erb-config-gen:19-70c45ccd33d3772cd6519e1f7dfe2cf5c2bc7b0e" % configs.registry;
local opencensusImage = "%s/dva/opencensus-service:13-75d5d20e22eec757a5399028a945fa0851bab367" % configs.registry;

local volumes = [
    {
        name: "opencensus-conf-tpl",
        configMap: {
            name: configMapName,
        },
    },
    {
        name: "opencensus-conf-gen",
        emptyDir: {},
    },
];

local configMap = {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: configMapName,
        namespace: namespace,
    },
    data: {
        "opencensus.cluster-metrics-exporter.yaml.erb": configTemplate,
    },
};

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

local serviceAccount = {
    apiVersion: "v1",
    kind: "ServiceAccount",
    metadata: {
        name: name,
        namespace: namespace,
    },
    automountServiceAccountToken: true,
};

local clusterRole = {
    apiVersion: "rbac.authorization.k8s.io/v1beta1",
    kind: "ClusterRole",
    metadata: {
        name: name,
        namespace: namespace,
    },
    rules: [
        {
            nonResourceURLs: [
                "/metrics",
            ],
            verbs: [
                "get",
            ],
        },
    ],
};

local clusterRoleBinding = {
    apiVersion: "rbac.authorization.k8s.io/v1beta1",
    kind: "ClusterRoleBinding",
    metadata: {
        name: name,
        namespace: namespace,
    },
    roleRef: {
        apiGroup: "rbac.authorization.k8s.io",
        kind: "ClusterRole",
        name: name,
    },
    subjects: [
        {
            kind: "ServiceAccount",
            name: name,
            namespace: namespace,
        },
    ],
};

local deployment = {
    apiVersion: "apps/v1beta1",
    kind: "Deployment",
    metadata: {
        name: name,
        namespace: namespace,
        labels: {
            app: name,
        },
    },
    spec: {
        selector: {
            matchLabels: {
                app: name,
            },
        },
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    app: name,
                },
            },
            spec: {
                serviceAccountName: name,
                automountServiceAccountToken: true,
                volumes+: []
                    + volumes,
                initContainers: [
                    {
                        name: "prom-to-argus-init",
                        image: configGenImage,
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
                    {
                        name: "prom-to-argus",
                        image: opencensusImage,
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
            },
        },
    },
};

if featureFlag then {
    apiVersion: "v1",
    kind: "List",
    items: [
        serviceAccount,
        clusterRole,
        clusterRoleBinding,
        configMap,
        deployment,
    ],
} else "SKIP"
