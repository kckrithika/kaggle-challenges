local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

{
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
                        volumeMounts+: configs.filter_empty([
                            configs.cert_volume_mount,
                            configs.config_volume_mount,
                        ]),
                    }
                    
                    + configs.containerInPCN
                    + {
                        livenessProbe: {
                             httpGet: {
                                 path: "/healthz",
                                 port: 21546,
                             },
                             initialDelaySeconds: 30,
                             periodSeconds: 5,
                         },
                     },
                ],
                volumes+: configs.filter_empty([
                    configs.cert_volume,
                    configs.config_volume("bundle-controller"),
                ]),
                nodeSelector: {
                              } +
                              if configs.kingdom == "prd" then {
                                  master: "true",
                              } else {
                                  pool: configs.estate,
                              },
            } + configs.serviceAccount,
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
        } + configs.ownerLabel.sam
        + configs.pcnEnableLabel,
        name: "bundlecontroller",
        [if configs.kingdom == "vpod" then "namespace"]: "sam-system",
    },
}
