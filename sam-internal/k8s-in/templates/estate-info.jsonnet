local configs = import "config.jsonnet";
if configs.estate == "prd-samtest" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                containers: [
                    {
                        name: "estate-info",
                        image: configs.estate_info,
                        args:[],
                        volumeMounts: [
                            {
                                name: "certs",
                                mountPath: "/etc/certs"
                            }
                        ],
                        "ports": [
                        {
                            "containerPort": 9090,
                            "name": "estate-info",
                        }
                        ],
                      livenessProbe: {
                           initialDelaySeconds: 15,
                           httpGet: {
                               path: "/",
                               port: 9090
                           },
                           timeoutSeconds: 10
                        },
                    }
                ],
                volumes: {
                    certsPath: {
                            path: "/data/certs",
                            name: "certs",
                    },
                    configPath: {
                            path: "/etc/kubernetes",
                            name: "config",
                    },
                },
                nodeSelector: {
                    pool: configs.estate
                } +
                if configs.estate == "prd-samtest" then {
                    // In the case of samtest, we deploy only to master so we can assimilate the control-estate
                    // minions to consumer minions and extrapolate the required permissions for those nodes.
                    // When the testing of authorization is done, we can move back to normal (any node of the control-estate)
                    master: "true"
                } else {},
            },
            metadata: {
                labels: {
                    name: "estate-info",
                    apptype: "server"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "estate-info"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "estate-info"
        },
        name: "estate-info",
        namespace: "sam-system"
    }
} else "SKIP"
