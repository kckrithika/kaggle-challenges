local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate != "prd-sam" && configs.estate != "prd-samdev" && configs.kingdom != "cdu" && configs.kingdom != "frf" then
{
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "snapshoter",
        } + configs.ownerLabel.sam,
        name: "snapshoter",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                name: "snapshoter",
            },
        },
        template: {
            metadata: {
                labels: {
                    apptype: "control",
                    name: "snapshoter",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
            spec: configs.specWithKubeConfigAndMadDog {
                containers: [configs.containerWithKubeConfigAndMadDog {
                    command: [
                        "/sam/snapshoter",
                        "--config=/config/snapshoter.json",
                        "--hostsConfigFile=/sfdchosts/hosts.json",
                        "--v=4",
                        "--alsologtostderr",
                    ],
                    volumeMounts+: [
                        configs.sfdchosts_volume_mount,
                        configs.config_volume_mount,
                        configs.cert_volume_mount,
                    ],
                    livenessProbe: {
                        httpGet: {
                            path: "/",
                            port: 9095,
                        },
                        initialDelaySeconds: 20,
                        periodSeconds: 20,
                        timeoutSeconds: 20,
                    },
                    image: samimages.hypersam,
                    name: "snapshoter",
                }],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    configs.config_volume("snapshoter"),
                ],
                hostNetwork: true,
                nodeSelector: {
                              } +
                              if configs.kingdom == "prd" then {
                                  master: "true",
                              } else {
                                  pool: configs.estate,
                              },
            },
        },
    },
} else "SKIP"
