local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-samtest" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "bundle-controller",
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/prabh.singh/hypersam:20180122_110429.24360ec6.dirty.prabhsingh-ltm5",
                        command: configs.filter_empty([
                           "/sam/bundlecontroller",
                           ]),
                       volumeMounts: configs.filter_empty([
                          configs.maddog_cert_volume_mount,
                          configs.cert_volume_mount,
                          configs.kube_config_volume_mount,
                       ]),
                       env: [
                          configs.kube_config_env,
                       ],
                    },
                ],
                volumes: configs.filter_empty([
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
                    name: "bundlecontroller",
                    apptype: "control",
                },
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
        },
        name: "bundlecontroller",
    },
} else "SKIP"
