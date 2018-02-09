local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

# Only private PROD info is provided by estate server currently
if !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom) then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-node-controller",
                        image: samimages.hypersam,
                        command: [
                            "/sam/watchdog",
                            "-role=NODECONTROLLER",
                            "-watchdogFrequency=10s",
                            "-alertThreshold=300s",
                        ]
                        + samwdconfig.shared_args
                        + ["-emailFrequency=24h"],
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
                    configs.config_volume("watchdog"),
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
                    name: "watchdog-node-controller",
                    apptype: "monitoring",
                },
               namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-node-controller",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-node-controller",
        },
        name: "watchdog-node-controller",
        namespace: "sam-system",
    },
} else "SKIP"
