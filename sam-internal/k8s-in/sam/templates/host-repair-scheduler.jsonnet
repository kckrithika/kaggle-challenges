local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "host-repair-scheduler",
        } + configs.ownerLabel.sam,
        name: "host-repair-scheduler",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                name: "host-repair-scheduler",
            },
        },
        template: {
            metadata: {
                labels: {
                    apptype: "control",
                    name: "host-repair-scheduler",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
            spec: configs.specWithKubeConfigAndMadDog {
                containers: [configs.containerWithKubeConfigAndMadDog {
                    name: "host-repair-scheduler",
                    image: samimages.hypersam,
                    command: [
                        "/sam/host-repair-scheduler",
                        "--config=/config/host-repair-scheduler.json",
                        "-v=0",
                    ],
                    volumeMounts+: [
                        configs.sfdchosts_volume_mount,
                        configs.config_volume_mount,
                        configs.cert_volume_mount,
                    ],
                }],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    configs.config_volume("host-repair-scheduler"),
                ],
                hostNetwork: true,
                nodeSelector: {
                    master: "true",
                },
            },
        },
    },
} else "SKIP"
