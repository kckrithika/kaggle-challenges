local configs = import "config.jsonnet";
local storageimages = import "storageimages.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";
local storageutils = import "storageutils.jsonnet";

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
                initContainers: [
                    {} +
                    storageutils.log_init_container(
                        storageimages.loginit,
                        "fds",
                        0,
                        0,
                        "root"
                    ),
                ],
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
                ] + if configs.estate == "prd-sam_storage" then [{
                // Pump prometheus metrics to argus. Start out in prd-sam_storage only for now --
                // the DCCoordinates aren't correctly being set yet for fds, so the metrics from two
                // different estates would all funnel into one bucket.
                // TODO: remove this condition once sfms supports environment variable overrides for DCCoordinates.
                    name: "sfms",
                    image: storageimages.sfms,
                    command: [
                        "/opt/sfms/bin/sfms",
                    ],
                    args: [
                        "-t",
                        "ajna_with_tags",
                        "-s",
                        "fds",
                        "-i",
                        '60',
                    ],
                    volumeMounts: [
                        {
                            name: "fds-sfms-config",
                            mountPath: "/opt/sfms/config/endpoints/sources/fds.json",
                            subPath: "fds.json",
                        },
                    ],
                    env: [
                        {
                            name: "SFDC_FUNNEL_VIP",
                            value: configs.funnelVIP,
                        },
                    ],
                }] else [],
                volumes: [
                    {
                        name: "fds-sfms-config",
                        configMap: {
                            name: "fds-sfms",
                        },
                    },
		]
                + storageutils.log_init_volumes()
		+ configs.filter_empty([
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
