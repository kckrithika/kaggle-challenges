local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

if configs.estate == "prd-samtest" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                containers: [
                    {
                        name: "estate-info-server",
                        image: samimages.estate_info,
                        args:[],
                        "ports": [
                        {
                            "containerPort": 9090,
                            "name": "estate-info-server",
                        }
                        ],
                      livenessProbe: {
                           initialDelaySeconds: 15,
                           httpGet: {
                               path: "/info",
                               port: 9090
                           },
                           timeoutSeconds: 10
                        },
                    }
                ],
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
                    name: "estate-info-server",
                    apptype: "server"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "estate-info-server"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "estate-info-server"
        },
        name: "estate-info-server",
        namespace: "sam-system"
    }
} else "SKIP"
