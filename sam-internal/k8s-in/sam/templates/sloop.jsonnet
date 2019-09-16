local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";
local mysql = import "sammysqlconfig.jsonnet";

if configs.estate == "prd-sam" then configs.deploymentBase("sam") {
    metadata+: {
        labels: {
            name: "sloop",
        } + configs.ownerLabel.sam,
        name: "sloop",
        namespace: "sam-system",
    },
    spec+: {
        replicas: 1,
        selector: {
            matchLabels: {
                name: "sloop",
            },
        },
        template: {
            metadata: {
                labels: {
                    name: "sloop",
                    apptype: "control",
                } + configs.ownerLabel.sam,
            },
            spec: {
                nodeSelector: {
                    pool: configs.estate,
                },
                containers: [
                    {
                        name: "sloop",
                        args: [
                            "-web-files-path=/webfiles/",
                            "--alsologtostderr",
                            "--config=/sloopconfig/sloop.yaml",
                        ],
                        command: [
                            "/bin/sloop",
                        ],
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/thargrove/sloop:thargrove-20190916_133447-708688e",
                        volumeMounts: [
                            {
                                name: "sloop-data",
                                mountPath: "/data/",
                            },
                            {
                                name: "sloopconfig",
                                mountPath: "/sloopconfig/",
                            },
                        ],
                        ports: [
                            {
                                containerPort: 8080,
                                protocol: "TCP",
                            },
                        ],
                    } + configs.ipAddressResourceRequest,
                    {
                        name: "prometheus",
                        args: [
                            "--config.file",
                            "/prometheusconfig/prometheus.json",
                        ],
                        image: samimages.prometheus,
                        volumeMounts: [
                            {
                                name: "prom-data",
                                mountPath: "/prometheus/",
                            },
                            {
                                name: "sloopconfig",
                                mountPath: "/prometheusconfig",
                            },
                        ],
                        ports: [
                            {
                                containerPort: 9090,
                                protocol: "TCP",
                            },
                        ],
                    },
                ],
                volumes: [
                    {
                        emptyDir: {
                            sizeLimit: "12Gi",
                        },
                        name: "sloop-data",
                    },
                    {
                        emptyDir: {
                            sizeLimit: "12Gi",
                        },
                        name: "prom-data",
                    },
                    {
                        configMap: {
                            name: "sloop",
                        },
                        name: "sloopconfig",
                    },
                ],
            } + configs.serviceAccount,
        },
    },
} else "SKIP"
