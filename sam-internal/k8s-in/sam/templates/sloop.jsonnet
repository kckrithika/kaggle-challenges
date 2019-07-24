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
                        args: [
                            "-web-files-path=/webfiles/",
                            "--alsologtostderr",
                        ],
                        command: [
                            "/bin/sloop",
                        ],
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/thargrove/sloop:thargrove-20190724_133755-af89d3f4",
                        volumeMounts: [
                            {
                                name: "sloop-data",
                                mountPath: "/data/",
                            },
                        ],
                        # TODO: Add liveness
                        #livenessProbe: {
                        #    httpGet: {
                        #        path: "/",
                        #        port: 64212,
                        #    },
                        #},
                        name: "sloop",
                        ports: [
                            {
                                containerPort: 8080,
                                protocol: "TCP",
                            },
                        ],
                    } + configs.ipAddressResourceRequest,
                ],
                volumes: [
                    {
                        hostPath: {
                            # Cowdata is ssd backed and typically ~900 GiB
                            path: "/cowdata/sloop",
                        },
                        name: "sloop-data",
                    },
                ],
            } + configs.serviceAccount,
        },
    },
} else "SKIP"
