local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" || configs.estate == "prd-samdev" || configs.estate == "vpod" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "bundle-controller",
                        image: samimages.hypersam,
                        command: configs.filter_empty([
                            "/sam/bundlecontroller",
                            "--config=/config/bundle-controller-config.json",
                            "--funnelEndpoint=" + configs.funnelVIP,
                        ]),
                        volumeMounts+: [
                            configs.cert_volume_mount,
                            configs.config_volume_mount,
                        ],
                    }
                    + (if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
                        livenessProbe: {
                             httpGet: {
                                 path: "/healthz",
                                 port: 21546,
                             },
                             initialDelaySeconds: 30,
                             periodSeconds: 5,
                         },
                     } else {}),
                ],
                volumes+: [
                    configs.cert_volume,
                    configs.config_volume("bundle-controller"),
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
                    name: "bundlecontroller",
                    apptype: "control",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "bundlecontroller",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "bundlecontroller",
        } + configs.ownerLabel.sam,
        name: "bundlecontroller",
        [if configs.kingdom == "vpod" then "namespace"]: "sam-system",
    },
} else "SKIP"
