local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

if samfeatureflags.rbacwd then {
    kind: "DaemonSet",
    spec: {
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "watchdog-rbac",
                        image: samimages.hypersam,
                        command: [
                                     "/sam/watchdog",
                                     "-role=RBAC",
                                     "-watchdogFrequency=180s",
                                     "-alertThreshold=1h",
                                     "-maxUptimeSampleSize=5",
                                     "-watchDogKind=" + $.kind,
                                 ]
                                 + samwdconfig.shared_args
                                 + ["-emailFrequency=336h"],
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
            },
            metadata: {
                labels: {
                    name: "watchdog-rbac",
                    apptype: "monitoring",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
        updateStrategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: "25%",
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
        } + configs.ownerLabel.sam,
        name: "watchdog-rbac",
    },
} else "SKIP"
