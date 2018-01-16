local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = import "samimages.jsonnet";
if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.kingdom == "frf" then {
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-rbac",
                        image: samimages.hypersam,
                        command: [
                            "/sam/watchdog",
                            "-role=RBAC",
                            "-watchdogFrequency=60s",
                            "-alertThreshold=1h",
                            "-maxUptimeSampleSize=5",
                        ]
                        + samwdconfig.shared_args
                        + ["-emailFrequency=24h"],
                        volumeMounts: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            configs.maddog_cert_volume_mount,
                            configs.cert_volume_mount,
                            configs.kube_config_volume_mount,
                            configs.config_volume_mount,
                        ]),
                        env: [
                             configs.kube_config_env,
                        ],
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    configs.config_volume("watchdog"),
                    ]),
            },
            metadata: {
                labels: {
                    name: "watchdog-rbac",
                    apptype: "monitoring",
                },
                namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-rbac",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-rbac",
        },
        name: "watchdog-rbac",
    },
} else "SKIP"
