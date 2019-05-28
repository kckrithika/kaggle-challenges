local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";
# This is a hack.  All watchdogs use the shared configMap, but hairpin had a duplicate set of flags
# and is not wired up to the configMap.  We should either pass through flags or have it use the configMap
local samwdconfigmap = import "configs/watchdog-config.jsonnet";
if false then {
    kind: "Deployment",
    spec: {
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxSurge: 0,
                maxUnavailable: 1,
            },
        },
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "watchdog-hairpindeployer",
                        image: samimages.hypersam,
                        command: [
                                     "/sam/watchdog",
                                     "-role=HAIRPINDEPLOYER",
                                     "-alertThreshold=1h",
                                     "-watchdogFrequency=120s",
                                     "-emailFrequency=336h",
                                     "-deployer-emailFrequency=336h",
                                     "-watchDogKind=" + $.kind,
                                 ]
                                 + samwdconfig.shared_args,
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
                    name: "watchdog-hairpindeployer",
                    apptype: "monitoring",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-hairpindeployer",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-hairpindeployer",
        } + configs.ownerLabel.sam,
        name: "watchdog-hairpindeployer",
    },
} else "SKIP"
