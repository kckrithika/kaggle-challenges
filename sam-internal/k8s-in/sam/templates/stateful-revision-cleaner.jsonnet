local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.estate == "phx-sam" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "stateful-revision-cleaner",
                        image: samimages.hypersam,
                        command: configs.filter_empty([
                            "/sam/stateful-revision-cleaner",
                            "--v=5",
                            "--k8sapiserver=",
                            "--namespacesToSkip=sam-watchdog,legostore,sam-system,sf-store",
                            configs.sfdchosts_arg,
                        ]),
                        volumeMounts+: [
                            configs.sfdchosts_volume_mount,
                            configs.cert_volume_mount,
                        ],
                    },
                ],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
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
                    name: "stateful-revision-cleaner",
                    apptype: "control",
                } + configs.ownerLabel.sam,
            },
        },
        selector: {
            matchLabels: {
                name: "stateful-revision-cleaner",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "stateful-revision-cleaner",
        } + configs.ownerLabel.sam,
        name: "stateful-revision-cleaner",
        namespace: "sam-system",
    },
} else "SKIP"
