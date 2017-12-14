local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = import "samimages.jsonnet";
if configs.kingdom == "prd" || configs.kingdom == "frf" then {
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-maddogcert",
                        image: samimages.hypersam,
                        command: [
                            "/sam/watchdog",
                            "-role=MADDOGCERT",
                            "-watchdogFrequency=10m",
                            "-alertThreshold=30m",
                            "-emailFrequency=1h",
                        ]
                        + samwdconfig.shared_args,
                        volumeMounts: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            configs.config_volume_mount,
                            configs.cert_volume_mount,
                            configs.maddog_cert_volume_mount,
                        ]),
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.config_volume("watchdog"),
                    configs.cert_volume,
                    configs.maddog_cert_volume,
                ]),
            },
            metadata: {
                labels: {
                    name: "watchdog-maddogcert",
                    apptype: "monitoring",
                    daemonset: "true",
                },
               namespace: "sam-system",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-maddogcert",
        },
        name: "watchdog-maddogcert",
    },
} else "SKIP"
