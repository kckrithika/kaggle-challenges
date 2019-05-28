local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-samtest" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "watchdog-artifactory",
                        image: samimages.hypersam,
                        command: [
                                    "/sam/watchdog",
                                    "--role=ARTIFACTORY",
                                    "--emailFrequency=336h",
                                    "--watchdogFrequency=30m",
                                    "--alertThreshold=1h",
                                    "--enableEmailPerCheckerInstance=true",
                                    "--recipient=",
                                    "--sender=sam@salesforce.com",
                                 ]
                                 + samwdconfig.shared_args,
                        volumeMounts+: [
                            configs.sfdchosts_volume_mount,
                            configs.config_volume_mount,
                            configs.cert_volume_mount,
                        ],
                    },
                ],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.config_volume("watchdog"),
                    configs.cert_volume,
                ],
                nodeSelector: {} + if !utils.is_production(configs.kingdom) then { master: "true" } else { pool: configs.estate },

            },
            metadata: {
                labels: {
                    name: "watchdog-artifactory",
                    apptype: "comparision",
                } + configs.ownerLabel.sam,
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-artifactory",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-artifactory",
        } + configs.ownerLabel.sam,
        name: "watchdog-artifactory",
        namespace: "sam-system",
    },
} else "SKIP"
