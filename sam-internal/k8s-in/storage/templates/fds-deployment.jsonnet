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
                    name: "fds-deployment",
                },
            },
            spec: {
                containers: [
                    {
                        name: "fds-deployment",
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-all/tnrp/storagecloud/faultdomainset:base-0000115-3cbd783",
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
