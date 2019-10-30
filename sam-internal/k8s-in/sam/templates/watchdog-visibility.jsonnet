local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-sam" || configs.estate == "prd-samtwo" then {
    kind: "Deployment",
    metadata: {
        labels: {
            name: "watchdog-visibility",
        },
        name: "watchdog-visibility",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "watchdog-visibility",
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/d.smith/hypersam:20191030_114804.b68098f1.clean.duncsmith-ltm1",
                        command: [
                                     "/sam/watchdog",
                                     "-role=VISIBILITY",
                                     "-watchdogFrequency=30s",
                                     "-alertThreshold=15m",
                                     "-watchDogKind=" + $.kind,
                                     # We are keeping this watchdog running because it emits customer-visible argus metrics for things like pod restarts
                                     "-emailFrequency=10000h",
                                     "--visibilityVirtualApi=http://pseudo-kubeapi.csc-sam.prd-sam.prd.slb.sfdc.net:40001/prd-sam",
                                     "--visibilityRealApi=shared0-samkubeapi1-1-prd.eng.sfdc.net:40000",
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
                nodeSelector: { master: "true" },
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
} else "SKIP"
