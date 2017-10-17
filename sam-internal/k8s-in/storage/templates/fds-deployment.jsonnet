local configs = import "config.jsonnet";

if configs.estate == "prd-sam_storage" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "fds-controller",
        },
        name: "fds-controller-deployment",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
                maxSurge: 0,
            },
        },
        template: {
            metadata: {
                labels: {
                    name: "fds-controller",
                },
            },
            spec: {
                containers: [
                    {
                        name: "fds-controller",
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-all/tnrp/storagecloud/faultdomainset:base-0000115-3cbd7831",
                        command: [
                            "/fds/fdsctl",
                            "controller",
                            "--logtostderr",
                            "-v",
                            "9",
                        ],
                        ports: [
                            {
                                containerPort: 8080,
                            },
                        ],
                        livenessProbe: {
                            httpGet: {
                                path: "/healthz",
                                port: 8080,
                            },
                        },
                    },
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
            },
        },
    },
} else "SKIP"
