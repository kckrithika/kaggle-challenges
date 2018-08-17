local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
{
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "watchdog-deployment",
                        image: samimages.hypersam,
                        command: [
                                     "/sam/watchdog",
                                     "-role=DEPLOYMENT",
                                     "-watchdogFrequency=10s",
                                     "-alertThreshold=1h",
                                     "-watchDogKind=" + $.kind,
                                 ]
                                 + samwdconfig.shared_args
                                 + ["-emailFrequency=24h"],
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
                              if configs.kingdom == "prd" then {
                                  master: "true",
                              } else {
                                  pool: configs.estate,
                              },
            },
            metadata: {
                labels: {
                    name: "watchdog-deployment",
                    apptype: "monitoring",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-deployment",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-deployment",
        } + configs.ownerLabel.sam,
        name: "watchdog-deployment",
    },
}
