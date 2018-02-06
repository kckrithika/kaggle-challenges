local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = import "samimages.jsonnet";
if configs.kingdom == "prd" && configs.estate != "prd-sam_storage" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-sdp",
                        image: samimages.hypersam,
                        command: [
                            "/sam/watchdog",
                            "-role=SDP",
                            "-sdpEndpoint=http://localhost:39999",
                            "-watchdogFrequency=10s",
                            "-alertThreshold=300s",
                            "-emailFrequency=24h",
                        ]
                       /* + (if configs.estate == "prd-samtest" then [
                              "--breakwatchdogsdp",
                        ] else [])*/
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
                nodeSelector: {
                    pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "watchdog-sdp",
                    apptype: "monitoring",
                },
                namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-sdp",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-sdp",
        },
        name: "watchdog-sdp",
    },
} else "SKIP"
