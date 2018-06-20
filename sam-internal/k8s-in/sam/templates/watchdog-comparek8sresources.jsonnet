local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local mysql = import "sammysqlconfig.jsonnet";

if configs.estate == "prd-samtest" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-comparek8sresources",
                        image: samimages.hypersam,
                        command: [
                                    "/sam/watchdog",
                                    "--role=COMPAREK8SRESOURCES",
                                    "--emailFrequency=1h",
                                    "--enableEmailPerCheckerInstance=true",
                                    "--deployer-recipient=small@salesforce.com,rbhat@salesforce.com,xiao.zhou@salesforce.com",
                                 ]
                                 + samwdconfig.shared_args,
                        volumeMounts: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            configs.config_volume_mount,
                            configs.cert_volume_mount,
                        ]),
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.config_volume("watchdog"),
                    configs.cert_volume,
                ]),
                nodeSelector: {
                    pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "watchdog-comparek8sresources",
                    apptype: "comparision",
                },
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-comparek8sresources",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-comparek8sresources",
        } + if configs.estate == "prd-samdev" then {
                  owner: "sam",
                } else {},
        name: "watchdog-comparek8sresources",
        namespace: "sam-system",
    },
} else "SKIP"
