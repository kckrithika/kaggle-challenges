local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";
{
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "watchdog-visibility",
                        image: samimages.hypersam,
                        command: [
                                     "/sam/watchdog",
                                     "-role=VISIBILITY",
                                     "-watchdogFrequency=30s",
                                     "-alertThreshold=15m",
                                     "-watchDogKind=" + $.kind,
                                     # We are keeping this watchdog running because it emits customer-visible argus metrics for things like pod restarts
                                     "-emailFrequency=10000h",
                                    ]
                                 + samwdconfig.shared_args
                                 + (if configs.estate == "prd-sam" || configs.estate == "prd-samtwo" then samwdconfig.low_urgency_pagerduty_args else []),
                        volumeMounts+: [
                            configs.sfdchosts_volume_mount,
                            configs.cert_volume_mount,
                            configs.config_volume_mount,
                        ],
                    },
                ],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    configs.config_volume("watchdog"),
                ],
                nodeSelector: {master: "true"},
            },
            metadata: {
                labels: {
                    name: "watchdog-visibility",
                    apptype: "monitoring",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-visibility",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-visibility",
        } + configs.ownerLabel.sam,
        name: "watchdog-visibility",
    },
}
