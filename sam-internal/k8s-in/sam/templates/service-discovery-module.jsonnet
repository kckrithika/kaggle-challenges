local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sam" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                containers: [
                    {
                        name: "service-discovery-module",
                        image: samimages.hypersam,
                        command: configs.filter_empty([
                            "/sam/service-discovery-module",
                            "-namespaceFilter=user-kdhabalia,cache-as-a-service-sp2,gater,user-prabhs",
                            "-zkIP=" + configs.zookeeperip,
                            "-funnelEndpoint=" + configs.funnelVIP,
                            configs.sfdchosts_arg,
                        ]),
                            env: [
                          configs.kube_config_env,
                        ],
                        volumeMounts: configs.filter_empty([
                          configs.sfdchosts_volume_mount,
                          configs.maddog_cert_volume_mount,
                          configs.cert_volume_mount,
                          configs.kube_config_volume_mount,
                       ]),
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                ]),
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
                },
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
        },
        name: "service-discovery-module",
        namespace: "sam-system",
    },
} else "SKIP"
