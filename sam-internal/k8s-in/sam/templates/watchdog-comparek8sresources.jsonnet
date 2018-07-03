local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local mysql = import "sammysqlconfig.jsonnet";

if configs.estate == "prd-samdev" || configs.estate == "prd-samtest" then {
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
                                    "--deployer-recipient=small@salesforce.com,xiao.zhou@salesforce.com,rbhat@salesforce.com,prabh.singh@salesforce.com",
                                    "--publishAlertsToKafka=false",
                                    "--publishAllReportsToKafka=false",
                                    "--context=/Users/small/.kube/config",
                                 ]
                                 + samwdconfig.shared_args,
                        volumeMounts: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            configs.config_volume_mount,
                            configs.cert_volume_mount,
                            configs.maddog_cert_volume_mount,
                            configs.kube_config_volume_mount,
                        ]),
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.config_volume("watchdog"),
                    configs.cert_volume,
                    configs.maddog_cert_volume,
                    configs.kube_config_volume,
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
        } + configs.ownerLabel.sam,
        name: "watchdog-comparek8sresources",
        namespace: "sam-system",
    },
} else "SKIP"
