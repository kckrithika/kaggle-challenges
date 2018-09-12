local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-samtest" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "watchdog-comparek8sresources2",
                        image: samimages.hypersam,
                        command: [
                                    "/sam/watchdog",
                                    "--role=COMPAREK8SRESOURCES",
                                    "--emailFrequency=24h",
                                    "--enableEmailPerCheckerInstance=true",
                                    "--recipient=small@salesforce.com,xiao.zhou@salesforce.com,rbhat@salesforce.com,prabh.singh@salesforce.com",
                                    "--sender=sam@salesforce.com",
                                 ]
                                 + samwdconfig.shared_args,
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
                nodeSelector: {} + if configs.kingdom == "prd" then { master: "true" } else { pool: configs.estate },

            },
            metadata: {
                labels: {
                    name: "watchdog-comparek8sresources2",
                    apptype: "comparision",
                } + configs.ownerLabel.sam,
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-comparek8sresources2",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-comparek8sresources2",
        } + configs.ownerLabel.sam,
        name: "watchdog-comparek8sresources2",
        namespace: "sam-system",
    },
} else "SKIP"
