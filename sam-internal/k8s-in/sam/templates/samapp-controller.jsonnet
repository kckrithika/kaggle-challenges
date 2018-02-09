local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

// Only for testing purpose
if configs.estate == "prd-samtest" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "samapp-controller",
                        image: samimages.hypersam,
                        command: configs.filter_empty([
                           "/sam/samapp-controller",
                           "--v=3",
                           "--logtostderr=true",
                           "--config=/config/samapp-controller-config.json",
                           configs.sfdchosts_arg,
                           ]) + (if !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom) then [
                           # Kept here because of the use of the envvar. Keep in sync with the config.
                           "--madkubEndpoint=" + "https://$(MADKUBSERVER_SERVICE_HOST):32007",
                           ] else []),
                       volumeMounts: configs.filter_empty([
                          configs.sfdchosts_volume_mount,
                          configs.maddog_cert_volume_mount,
                          configs.cert_volume_mount,
                          configs.kube_config_volume_mount,
                          configs.config_volume_mount,
                       ]),
                       env: [
                          configs.kube_config_env,
                       ],
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    configs.config_volume("samapp-controller"),
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
                    name: "samappcontroller",
                    apptype: "control",
                },
               namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "samappcontroller",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "samappcontroller",
        },
        name: "samappcontroller",
    },
} else "SKIP"
