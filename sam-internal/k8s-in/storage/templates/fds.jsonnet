local configs = import "config.jsonnet";
local storageimages = import "storageimages.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";
local storageutils = import "storageutils.jsonnet";

if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" || configs.estate == "phx-sam" then {
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
                        7337,
                        7337,
                        "sfdc"
                    ),
                ],
                containers: [
                    {
                        name: "fds",
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
                        volumeMounts:
                            storageutils.log_init_volume_mounts()
                            + configs.filter_empty([
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
                    {
                        // Pump prometheus metrics to argus.
                        name: "sfms",
                        image: storageimages.sfms,
                        command: [
                            "/opt/sfms/bin/sfms",
                        ],
                        args: [
                            "-t",
                            "ajna_with_tags",
                            "-s",
                            "prometheus",
                            "-i",
                            '60',
                        ],
                        env: storageutils.sfms_environment_vars("fds"),

                    },
                ],
                volumes: storageutils.log_init_volumes()
                + configs.filter_empty([
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
