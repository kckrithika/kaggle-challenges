local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";
local utils = import "util_functions.jsonnet";

# Only private PROD info is provided by estate server currently
if samfeatureflags.estatessvc then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "watchdog-estatesvc",
                        image: samimages.hypersam,
                        command: [
                                     "/sam/watchdog",
                                     "-role=ESTATESVC",
                                     "-watchdogFrequency=10s",
                                     "-alertThreshold=300s",
                                     "-watchDogKind=" + $.kind,
                                 ]
                                 + samwdconfig.shared_args
                                 + ["-emailFrequency=336h"],
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
                nodeSelector: {
                              } +
                              if !utils.is_production(configs.kingdom) then {
                                  master: "true",
                              } else {
                                  pool: configs.estate,
                              },
            },
            metadata: {
                labels: {
                    name: "watchdog-estatesvc",
                    apptype: "monitoring",
                } + configs.ownerLabel.sam,
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-estatesvc",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-estatesvc",
        } + configs.ownerLabel.sam,
        name: "watchdog-estatesvc",
        namespace: "sam-system",
    },
} else "SKIP"
