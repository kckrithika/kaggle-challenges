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
                        name: "watchdog-etcd-quorum",
                        image: samimages.hypersam,
                        command: [
                                     "/sam/watchdog",
                                     "-role=ETCDQUORUM",
                                     "-watchdogFrequency=10s",
                                     "-alertThreshold=2m",
                                     "-snoozedAlarms=etcdQuorumChecker=2018/11/12",
                                     "-watchDogKind=" + $.kind,
                                 ]
                                 + samwdconfig.pagerduty_args
                                 + samwdconfig.shared_args
                                 + (if configs.kingdom == "prd" then ["-emailFrequency=48h"] else ["-emailFrequency=6h"]),
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
                    pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "watchdog-etcd-quorum",
                    apptype: "monitoring",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-etcd-quorum",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-etcd-quorum",
        } + configs.ownerLabel.sam,
        name: "watchdog-etcd-quorum",
    },
}
