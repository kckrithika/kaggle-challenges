local configs = import "config.jsonnet";
local storageimages = (import "storageimages.jsonnet") + { templateFilename:: std.thisFile };
local storageutils = import "storageutils.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";

if configs.estate == "prd-sam_storage" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        name: "sfn-state-metrics",
        namespace: "sam-system",
    },
    spec: {
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
                        ports: [
                            {
                                containerPort: 8080,
                                name: "sfn-metrics",
                            },
                        ],
                        volumeMounts:
                            storageutils.log_init_volume_mounts()
                            + [{
                                    name: "sfn-config-dir",
                                    mountPath: "/sfn-state-metrics/sfn-selectors.yaml",
                                    subPath: "sfn-selectors.yaml",
                            }]
                            + configs.filter_empty([
                                configs.maddog_cert_volume_mount,
                                configs.cert_volume_mount,
                                configs.kube_config_volume_mount,
                            ]),
                        env: configs.filter_empty([
                            configs.kube_config_env,
                        ]),
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
                        env: [
                            {
                                name: "MC_ZK_SERVERS",
                                value: storageconfigs.perEstate.sfstore.zkServer[configs.estate],
                            },
                            {
                                name: "MC_PORT",
                                value: "8080",
                            },
                        ] + storageutils.sfms_environment_vars("sfn-state-metrics"),
                    },
                ],
            },
        },
    },
} else "SKIP"
