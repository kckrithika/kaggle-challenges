local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

# Only private PROD info is provided by estate server currently
if !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom) then {
    kind: "Deployment",
    spec: {
        replicas: 3,
        template: {
            spec: {
                securityContext: {
                    runAsUser: 0,
                    fsGroup: 0,
                },
                containers: [
                    {
                        name: "estate-server",
                        image: samimages.hypersam,
                        command: [
                            "/sam/estatesvc/script/estatesvc-wrapper.sh",
                            configs.kingdom,
                           "--funnelEndpoint=" + configs.funnelVIP,
                        ],
                        ports: [
                        {
                            containerPort: 9090,
                            name: "estate-server",
                        },
                        ],
                        livenessProbe: {
                           initialDelaySeconds: 15,
                           httpGet: {
                               path: "/info",
                               port: 9090,
                           },
                           timeoutSeconds: 10,
                        },
                        env: [
                            {
                                name: "NODE_NAME",
                                valueFrom: {
                                    fieldRef: {
                                        fieldPath: "spec.nodeName",
                                    },
                                },
                            },
                            {
                                name: "POD_NAME",
                                valueFrom: {
                                    fieldRef: {
                                        fieldPath: "metadata.name",
                                    },
                                },
                            },
                        ],
                    },
                ],
                nodeSelector: {
                } +
                if configs.kingdom == "prd" then {
                    master: "true",
                } else {
                     pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "estate-server",
                    apptype: "server",
                },
            },
        },
        selector: {
            matchLabels: {
                name: "estate-server",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "estate-server",
        },
        name: "estate-server",
        namespace: "sam-system",
    },
} else "SKIP"
