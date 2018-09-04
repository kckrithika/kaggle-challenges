local configs = import "config.jsonnet";
local storageimages = (import "storageimages.jsonnet") + { templateFilename:: std.thisFile };
local storageconfigs = import "storageconfig.jsonnet";
local storageutils = import "storageutils.jsonnet";

// Defines the list of estates where this service is enabled.
local enabledEstates = std.set([
    "prd-sam_storagedev",
]);

if std.setMember(configs.estate, enabledEstates) then configs.deploymentBase("storage") {
    metadata: {
        labels: {
            name: "zookeeperoperator",
            team: "storage-foundation",
            cloud: "storage",
        } + configs.ownerLabel.storage,
        name: "zookeeperoperator-deployment",
        namespace: "sam-system",
    },
    spec+: {
        replicas: 1,
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
                maxSurge: 0,
            },
        },
        minReadySeconds: 30,
        template: {
            metadata: {
                labels: {
                    name: "zookeeperoperator",
                    team: "storage-foundation",
                    cloud: "storage",
                },
            },
            spec: {
                containers: [
                    {
                        name: "zookeeperoperator",
                        image: storageimages.zookeeperoperator,
                        volumeMounts: configs.filter_empty([
                            {
                                name: "zookeeper-config",
                                mountPath: "/zkop/configs",
                            },
                            configs.maddog_cert_volume_mount,
                            configs.cert_volume_mount,
                            configs.kube_config_volume_mount,
                        ]),
                        env: [
                            configs.kube_config_env,
                        ],
                    },
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
                        env: storageutils.sfms_environment_vars("zookeeperoperator"),
                    },
                ],
                volumes: configs.filter_empty([
                    {
                        name: "zookeeper-config",
                        configMap: {
                            name: "zookeeper-configmap",
                        },
                    },
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                ]),
                nodeSelector: {
                    master: "true",
                },
            },
        },
    } + storageutils.revisionHistorySettings,
} else "SKIP"
