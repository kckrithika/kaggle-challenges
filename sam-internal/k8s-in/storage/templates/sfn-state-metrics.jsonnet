local configs = import "config.jsonnet";
local storageimages = (import "storageimages.jsonnet") + { templateFilename:: std.thisFile };
local storageutils = import "storageutils.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";

// Defines the list of estates where this service is enabled.
local enabledEstates = std.set([
    "prd-sam_storage",
    "prd-sam",
]);

local sfmsContainerLimits =
if configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" then {
    resources: {
        limits: {
            memory: "2Gi",
        },
        requests: {
            memory: "2Gi",
        },
    },
} else {};

// Init containers for the pod.
local initContainers = if storageimages.phase == "1" then {
    initContainers: [
        storageimages.log_init_container(
            storageimages.loginit,
            "sfms",
            7337,
            7337,
            "sfdc"
        ),
    ],
} else {};

local sfmsLogPathEnvVar = if storageimages.phase == "1" then [
    {
        name: "SFMS_LOGS_PATH",
        value: "/var/log/sfms",
    },
] else [];

if std.setMember(configs.estate, enabledEstates) then configs.deploymentBase("storage") {
    metadata: {
        name: "sfn-state-metrics",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.storage,
    },
    spec+: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "sfn-state-metrics",
                    team: "storage-foundation",
                    cloud: "storage",
                },
            },
            spec: {
                volumes: storageutils.log_init_volumes()
                + [
                    {
                        name: "sfn-config-dir",
                        configMap: {
                            name: "sfn-config",
                        },
                    },
                ]
                + configs.filter_empty([
                        configs.maddog_cert_volume,
                        configs.cert_volume,
                        configs.kube_config_volume,
                    ]),
                nodeSelector: {
                    master: "true",
                },
                containers: [
                    {
                        image: storageimages.sfnstatemetrics,
                        name: "sfn-state-metrics",
                        command: [
                            "/sfn-state-metrics/sfn-state-metrics",
                        ],
                        args: [
                            "--config",
                            "/etc/sfn-state-metrics/sfn-selectors.yaml",
                        ],
                        ports: [
                            {
                                containerPort: storageconfigs.serviceDefn.sfn_metrics_svc.health.port,
                                name: storageconfigs.serviceDefn.sfn_metrics_svc.health["port-name"],
                            },
                        ],
                        volumeMounts:
                            storageutils.log_init_volume_mounts()
                            + [{
                                    name: "sfn-config-dir",
                                    mountPath: "/etc/sfn-state-metrics",
                            }]
                            + configs.filter_empty([
                                configs.maddog_cert_volume_mount,
                                configs.cert_volume_mount,
                                configs.kube_config_volume_mount,
                            ]),
                        env: configs.filter_empty([
                            configs.kube_config_env,
                        ]),
                    } + configs.ipAddressResourceRequest,
                    {
                        // Pump prometheus metrics to argus.
                        name: "sfms",
                        image: storageimages.sfms,
                        command: [
                            "/opt/sfms/bin/sfms",
                        ],
                        args: [
                            "-j",
                            "prometheus",
                        ],
                        env: storageutils.sfms_environment_vars(storageconfigs.serviceDefn.sfn_metrics_svc.name),
                    } + sfmsContainerLimits,
                    storageutils.poddeleter_podspec(storageimages.maddogpoddeleter),
                ],
            },  //+ initContainers,
        },
    } + storageutils.revisionHistorySettings,
} else "SKIP"
