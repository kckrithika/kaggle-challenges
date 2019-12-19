local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "host-repair-rebooter",
        },
        name: "host-repair-rebooter",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                name: "host-repair-rebooter",
            },
        },
        template: {
            metadata: {
                labels: {
                    apptype: "control",
                    name: "host-repair-rebooter",
                },
                namespace: "sam-system",
            },
            spec: configs.specWithKubeConfigAndMadDog {
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "host-repair-rebooter",
                        image: samimages.hypersam,
                        command: [
                            "/sam/host-repair-rebooter",
                            "--config=/config/host-repair-rebooter.json",
                        ],
                        volumeMounts+: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            configs.cert_volume_mount,
                            configs.config_volume_mount,
                        ]),
                    },
],
                volumes+: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    configs.config_volume("host-repair-rebooter"),
                ]),
                hostNetwork: true,
                nodeSelector: {
                    master: "true",
                },
            },
        },
    },
} else "SKIP"
