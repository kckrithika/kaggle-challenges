local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = import "samimages.jsonnet";
if configs.estate == "prd-sam" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-manifestzip",
                        image: samimages.hypersam,
                        command: [
                            "/sam/watchdog",
                            "-role=MANIFESTZIP",
                            "-watchdogFrequency=7m",
                            "-alertThreshold=10s",
                            "-emailFrequency=1h",
                        ]
                        + samwdconfig.shared_args,
                        volumeMounts: configs.filter_empty([
                          configs.sfdchosts_volume_mount,
                          {
                             mountPath: "/var/token",
                             name: "token",
                             readOnly: true,
                          },
                          configs.config_volume_mount,
                          configs.cert_volume_mount,
                          configs.maddog_cert_volume_mount,
                       ]),
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    {
                        secret: {
                            secretName: "git-token",
                          },
                        name: "token",
                    },
                    configs.config_volume("watchdog"),
                    configs.cert_volume,
                    configs.maddog_cert_volume,
                ]),
                nodeSelector: {
                    pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "watchdog-manifestzip",
                    apptype: "monitoring",
                },
                namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-manifestzip",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-manifestzip",
        },
        name: "watchdog-manifestzip",
    },
} else "SKIP"
