local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then
configs.deploymentBase("sam") {
    spec+: {
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        image: samimages.hypersam,
                        command: [
                                     "/sam/watchdog",
                                     "-role=DNS",
                                     "-watchdogFrequency=5s",
                                     "-alertThreshold=3m",
                                     "-watchDogKind=" + $.kind,
                                 ]
                                 + samwdconfig.shared_args
                                 + samwdconfig.low_urgency_pagerduty_args
                                 + (if configs.kingdom == "prd" then ["-emailFrequency=48h"] else ["-emailFrequency=12h"]),
                        volumeMounts+: [
                            configs.sfdchosts_volume_mount,
                            configs.config_volume_mount,
                            configs.cert_volume_mount,
                        ],
                        name: "watchdog",
                        resources: {
                            requests: {
                                cpu: "0.5",
                                memory: "300Mi",
                            },
                            limits: {
                                cpu: "0.5",
                                memory: "300Mi",
                            },
                        },
                    },
                ],
                dnsPolicy: "Default",
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    configs.config_volume("watchdog"),
                ],
                # not sure if this is useful at all
                nodeSelector: if utils.is_public_cloud(configs.kingdom) then {
                } else {
                    master: "true",
                },
            },
            metadata: {
                labels: {
                    app: "watchdog-dns",
                    apptype: "monitoring",
                    daemonset: "true",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
    },
    metadata+: {
        labels: {
            name: "watchdog-dns",
        },
        name: "watchdog-dns",
    },
} else "SKIP"
