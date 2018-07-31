local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
if configs.estate == "prd-sam" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-pullrequest",
                        image: samimages.hypersam,
                        command: [
                                     "/sam/watchdog",
                                     "-role=PULLREQUEST",
                                     "-watchdogFrequency=3m",
                                     "-alertThreshold=10s",
                                     "-emailFrequency=1h",
                                     "-watchDogKind=" + $.kind,
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
                        ] + (if configs.kingdom == "prd" then [configs.kube_config_volume_mount] else [])),
                        [if configs.kingdom == "prd" then "env"]: [configs.kube_config_env],
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
                ] + (if configs.kingdom == "prd" then [configs.kube_config_volume] else [])),
                nodeSelector: {
                    pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "watchdog-pullrequest",
                    apptype: "monitoring",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-pullrequest",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-pullrequest",
        } + configs.ownerLabel.sam,
        name: "watchdog-pullrequest",
    },
} else "SKIP"
