local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
if configs.estate == "prd-sam" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "watchdog-pullrequest",
                        image: samimages.hypersam,
                        command: [
                                     "/sam/watchdog",
                                     "-role=PULLREQUEST",
                                     "-watchdogFrequency=4m",
                                     "-alertThreshold=10s",
                                     "-emailFrequency=1h",
                                     "-watchDogKind=" + $.kind,
                                 ]
                                 + samwdconfig.shared_args,
                        volumeMounts+: [
                            configs.sfdchosts_volume_mount,
                            {
                                mountPath: "/var/token",
                                name: "token",
                                readOnly: true,
                            },
                            configs.config_volume_mount,
                            configs.cert_volume_mount,
                        ],
                    },
                ],
                volumes+: [
                    configs.sfdchosts_volume,
                    {
                        secret: {
                            secretName: "git-token",
                        },
                        name: "token",
                    },
                    configs.config_volume("watchdog"),
                    configs.cert_volume,
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "watchdog-pullrequest",
                    apptype: "monitoring",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-pullrequest",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-pullrequest",
        } + configs.ownerLabel.sam,
        name: "watchdog-pullrequest",
    },
} else "SKIP"
