local configs = import "config.jsonnet";
local storageimages = import "storageimages.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";

if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "fds-controller",
        },
        name: "fds-controller-deployment",
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
                    name: "fds-controller",
                },
            },
            spec: {
                containers: [
                    {
                        name: "fds-controller",
                        image: storageimages.fdscontroller,
                        ports: [
                            {
                                containerPort: 8080,
                            },
                        ],
                        livenessProbe: {
                            httpGet: {
                                path: "/healthz",
                                port: 8080,
                            },
                        },
                        readinessProbe: {
                            httpGet: {
                                path: "/healthz",
                                port: 8080,
                            },
                        },
                        volumeMounts: configs.filter_empty([
                            configs.maddog_cert_volume_mount,
                            configs.cert_volume_mount,
                            configs.kube_config_volume_mount,
                        ]),
                        env: [
                            configs.kube_config_env,
                            {
                                name: "FDS_ASSUMED_CAPACITY_PER_POD",
                                value: storageconfigs.fds_per_pod_capacity,
                            },
                            {
                                name: "FDS_PROFILING",
                                value: storageconfigs.fds_profiling,
                            },
                        ],
                    },
                ],
                volumes: configs.filter_empty([
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                ]),
                nodeSelector: {
                } +
                if configs.estate == "prd-sam" then {
                    master: "true",
                } else {
                    pool: configs.estate,
                },
            },
        },
    },
} else "SKIP"
