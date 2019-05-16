local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "kube-state-metrics",
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/lizhang/kube-state-metrics:v1.4.0",
                        command: configs.filter_empty([
                            "/kube-state-metrics",
                            "--kubeconfig=/kubeconfig/kubeconfig-platform",
                            "--port=8080",
                            "--telemetry-port=8081",
                        ]),
                        volumeMounts+: [
                            configs.cert_volume_mount,
                        ],
                        livenessProbe: {
                             httpGet: {
                                 path: "/healthz",
                                 port: 8080,
                             },
                             initialDelaySeconds: 5,
                             periodSeconds: 5,
                         },
                    } + configs.ipAddressResourceRequest,
                ],
                volumes+: [
                    configs.cert_volume,
                ],
                nodeSelector: {
                                  pool: configs.estate,
                              },
            },
            metadata: {
                labels: {
                    name: "kube-state-metrics",
                } + configs.ownerLabel.sam,
                namespace: "kube-system",
            },
        },
        selector: {
            matchLabels: {
                name: "kube-state-metrics",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "kube-state-metrics",
        },
        name: "kube-state-metrics",
        namespace: "kube-system",
    },
} else "SKIP"
