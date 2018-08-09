local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

{
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-etcd-quorum",
                        image: samimages.hypersam,
                        command: [
                                     "/sam/watchdog",
                                     "-role=ETCDQUORUM",
                                     "-watchdogFrequency=10s",
                                     "-alertThreshold=2m",
                                     "-watchDogKind=" + $.kind,
                                 ]
                                 + samwdconfig.pagerduty_args
                                 + samwdconfig.shared_args
                                 + (if configs.kingdom == "prd" then ["-emailFrequency=48h"] else ["-emailFrequency=6h"]),
                        volumeMounts: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            configs.maddog_cert_volume_mount,
                            configs.cert_volume_mount,
                            configs.config_volume_mount,
                            configs.kube_config_volume_mount,
                        ]),
                        env: [
                            configs.kube_config_env,
                        ],
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.config_volume("watchdog"),
                    configs.kube_config_volume,
                ]),
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
