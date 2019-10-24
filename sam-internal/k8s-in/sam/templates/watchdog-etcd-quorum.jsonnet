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
                                     "-watchDogKind=" + $.kind,
                                 ] + (
                                         if configs.kingdom == "prd" && configs.estate == "prd-samtest" then [
                                             "--caFile=/etc/pki_service/ca/cabundle.pem",
                                             "--keyFile=/etc/pki_service/platform/platform-client/keys/platform-client-key.pem",
                                             "--certFile=/etc/pki_service/platform/platform-client/certificates/platform-client.pem",
                                         ] else []
                                  )
                                 + samwdconfig.pagerduty_args
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
