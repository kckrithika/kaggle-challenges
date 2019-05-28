local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local mysql = import "sammysqlconfig.jsonnet";

if configs.estate == "prd-sam" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                dnsPolicy: "ClusterFirstWithHostNet",
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "watchdog-samsql",
                        image: samimages.hypersam,
                        command: [
                                    "/sam/watchdog",
                                    "--role=GLOBAL",
                                    "--sqlDbUsername=watchdog",
                                    "--sqlDbPasswordFile=/var/secrets/watchdog",
                                    "--sqlDbHostname=" + mysql.readOnlyHostName,
                                    "--sqlK8sResourceDbName=" + mysql.visibilityDBName,
                                    "--sqlDbPort=3306",
                                    "--sqlQueryFile=/var/queries/watchdog-samsql-queries.jsonnet",
                                    "--sqlAlertFile=/var/queries/watchdog-samsql-profiles.jsonnet",
                                    "--emailFrequency=336h",
                                    "--enableEmailPerCheckerInstance=true",
                                    "-v=5",
                                    "--alsologtostderr",
                                     "-watchDogKind=" + $.kind,
                                 ]
                                 + samwdconfig.shared_args,
                        volumeMounts+: [
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
                        ],
                    },
                ],
                volumes+: [
                    {
                        name: "mysql",
                        secret: {
                            secretName: "mysql-passwords",
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
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "watchdog-samsql",
                    apptype: "monitoring",
                } + configs.ownerLabel.sam,
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
        } + configs.ownerLabel.sam,
        name: "watchdog-samsql",
        namespace: "sam-system",
    },
} else "SKIP"
