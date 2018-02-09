local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
{
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-apiserverlb",
                        image: samimages.hypersam,
                        command: configs.filter_empty([
                            "/sam/watchdog",
                            "-role=APISERVERLB",
                            "-watchdogFrequency=60s",
                            "-alertThreshold=5m",
                        ])
                        + samwdconfig.pagerduty_args
                        + samwdconfig.shared_args
                        + (if configs.kingdom == "prd" then ["-emailFrequency=72h"] else ["-emailFrequency=12h"]),
                        volumeMounts: configs.filter_empty([
                          configs.sfdchosts_volume_mount,
                          configs.maddog_cert_volume_mount,
                          configs.cert_volume_mount,
                          configs.config_volume_mount,
                        ]),
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
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
                    name: "watchdog-apiserverlb",
                    apptype: "monitoring",
                },
               namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-apiserverlb",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-apiserverlb",
        },
        name: "watchdog-apiserverlb",
    },
}
