local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sam" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "service-discovery-module",
                        image: samimages.hypersam,
                        command: configs.filter_empty([
                            "/sam/service-discovery-module",
                            "-namespaceFilter=user-kdhabalia,cache-as-a-service-sp2,gater,user-prabhs",
                            "-zkIP=" + configs.zookeeperip,
                            "-funnelEndpoint=" + configs.funnelVIP,
                            configs.sfdchosts_arg,
                        ]),
                        volumeMounts+: [
                            configs.sfdchosts_volume_mount,
                            configs.cert_volume_mount,
                        ],
                    } + configs.ipAddressResourceRequest,
                ],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
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
                    name: "service-discovery-module",
                    apptype: "control",
                } + configs.ownerLabel.sam,
            },
        },
        selector: {
            matchLabels: {
                name: "service-discovery-module",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "service-discovery-module",
        } + configs.ownerLabel.sam,
        name: "service-discovery-module",
        namespace: "sam-system",
    },
} else "SKIP"
