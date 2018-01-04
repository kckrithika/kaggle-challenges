local configs = import "config.jsonnet";
local storageimages = import "storageimages.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";

if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "sfstoreoperator",
        },
        name: "sfstoreoperator-deployment",
        namespace: "sam-system",
    },
    spec: {
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
                    name: "sfstoreoperator",
                },
            },
            spec: {
                containers: [
                    {
                        name: "sfstoreoperator",
                        image: storageimages.sfstoreoperator,
                        volumeMounts: configs.filter_empty([
                            {
                                name: "sfstore-config",
                                mountPath: "/sfo/configs",
                            },
                            configs.maddog_cert_volume_mount,
                            configs.cert_volume_mount,
                            configs.kube_config_volume_mount,
                        ]),
                        env: [
                            configs.kube_config_env,
                        ],
                    },
                ],
                volumes: configs.filter_empty([
                    {
                        name: "sfstore-config",
                        configMap: {
                            name: "sfstore-configmap",
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
    },
} else "SKIP"
