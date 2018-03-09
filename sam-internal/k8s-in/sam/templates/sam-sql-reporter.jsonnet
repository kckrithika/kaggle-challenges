local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "samsqlreporter",
        },
        name: "samsqlreporter",
        namespace: "sam-system",
    },
    spec: {
        replicas: 2,
        selector: {
            matchLabels: {
                name: "samsqlreporter",
            },
        },
        template: {
            metadata: {
                labels: {
                    name: "samsqlreporter",
                    apptype: "control",
                },
            },
            spec: {
                nodeSelector: {
                    pool: configs.estate,
                },
                containers: [
                    {
                        args: [
                            "--dbPasswordFile=/var/secrets/mysql.txt",
                            "-v=5",
                            "--alsologtostderr",
                            "--port=64212",
                            "--queryFile=/var/queries/sam-sql-queries.json",
                        ],
                        command: [
                            "/sam/sam-sql-reporter",
                        ],
                        image: samimages.hypersam,
                        livenessProbe: {
                            httpGet: {
                                path: "/",
                                port: 64212,
                            },
                        },
                        name: "samsqlreporter",
                        ports: [
                            {
                                containerPort: 64212,
                                protocol: "TCP",
                            },
                        ],
                        volumeMounts: [
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
                        ],
                    },
                ],
                volumes: [
                    {
                        name: "mysql",
                        secret: {
                            secretName: "mysql",
                        },
                    },
                    {
                        name: "queries",
                        configMap: {
                            name: "samsqlqueries",
                        },
                    },
                ],
            },
        },
    },
} else "SKIP"
