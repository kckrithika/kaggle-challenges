local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = import "samimages.jsonnet";
if configs.kingdom == "prd" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-proxy",
                        image: samimages.hypersam,
                        command: [
                            "/sam/watchdog",
                            "-role=K8SPROXY",
                            "-k8sproxyEndpoint=http://localhost:40000",
                            "-watchdogFrequency=10s",
                            "-alertThreshold=300s",
                            "-emailFrequency=48h",
                        ]
                        + samwdconfig.shared_args,
                        volumeMounts: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            configs.config_volume_mount,
                        ])
                        + (
                            if configs.kingdom == "prd" then
                                [configs.cert_volume_mount, configs.maddog_cert_volume_mount]
                            else []
                        ),
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.config_volume("watchdog"),
                ])
                + (
                    if configs.kingdom == "prd" then
                        [configs.cert_volume, configs.maddog_cert_volume]
                    else []
                ),
                nodeSelector: {
                } +
                if configs.kingdom == "prd" then {
                    master: "true",
                } else {
                     pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "watchdog-proxy",
                    apptype: "monitoring",
                },
               namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-proxy",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-proxy",
        },
        name: "watchdog-proxy",
    },
} else "SKIP"
