local configs = import "config.jsonnet";
local storageimages = import "storageimages.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";
local storageutils = import "storageutils.jsonnet";

if configs.estate == "prd-sam" || configs.estate == "phx-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "cephoperator",
            team: "legostore",
            cloud: "storage",
        },
        name: "cephoperator-deployment",
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
                    name: "cephoperator",
                    team: "legostore",
                    cloud: "storage",
                },
            },
            spec: {
                initContainers: [
                    {} +
                    storageutils.log_init_container(
                        storageimages.loginit,
                        "ceph-operator",
                        0,
                        0,
                        "root"
                    ),
                ],
                containers: [
                    {
                        name: "cephoperator",
                        image: storageimages.cephoperator,
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
                                name: "K8S_PLATFORM",
                                value: configs.estate,
                            },
                            {
                                name: "CEPH_INIT_CONTAINER",
                                value: storageimages.loginit,
                            },
                            {
                                name: "CEPH_DAEMON_IMAGE_PATH",
                                value: storageimages.cephdaemon_image_path,
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
                        env: storageutils.sfms_environment_vars("ceph-operator"),
                    },
                ],
                volumes:
                    storageutils.log_init_volumes()
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
