local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
if configs.estate == "prd-sam" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                containers: [
                    {
                        name: "watchdog-samsql",
                        image: samimages.hypersam,
                        command: [
                                    "/sam/watchdog",
                                    "--role=MYSQL",
                                    "--sqlDbUsername=root",
                                    "--sqlDbPasswordFile=/var/secrets/mysql.txt",
                                    "--sqlDbHostname=mysql.csc-sam.prd-sam.prd.slb.sfdc.net",
                                    "--sqlK8sResourceDbName=sam_kube_resource",
                                    "--sqlDbPort=3306",
                                    "--sqlQueryFile=/var/queries/watchdog-samsql-queries.jsonnet",
                                    "--emailFrequency=24h",
                                    "-v=5",
                                    "--alsologtostderr",
                                 ]
                                 + samwdconfig.shared_args,
                        volumeMounts: configs.filter_empty([
                            {
                                mountPath: "/var/secrets/",
                                name: "mysql",
                                readOnly: true,
                            },
                            {
                                mountPath: "/var/queries/",
                                name: "queries",
                                readOnly: true,
                            },
                            configs.sfdchosts_volume_mount,
                            configs.config_volume_mount,
                            configs.cert_volume_mount,
                            configs.maddog_cert_volume_mount,
                        ]),
                    },
                ],
                volumes: configs.filter_empty([
                    {
                        name: "mysql",
                        secret: {
                            secretName: "mysql",
                        },
                    },
                    {
                        name: "queries",
                        configMap: {
                            name: "watchdogsamsqlqueries",
                        },
                    },
                    configs.sfdchosts_volume,
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
                    name: "watchdog-samsql",
                    apptype: "monitoring",
                },
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-samsql",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-samsql",
        },
        name: "watchdog-samsql",
        namespace: "sam-system",
    },
} else "SKIP"
