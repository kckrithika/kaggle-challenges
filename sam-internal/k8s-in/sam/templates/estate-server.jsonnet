local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

if configs.kingdom == "prd" then {
    kind: "Deployment",
    spec: {
        replicas: 3,
        template: {
            spec: {
                securityContext: {
                    runAsUser: 0,
                    fsGroup: 0
                },
                containers: [
                    {
                        name: "estate-server",
                        image: ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/sam/hypersam:sam-0001248-9538cbb8,
                        command:[
                            "/sam/estatesvc/script/estatesvc-wrapper.sh",
                            configs.kingdom,
                           "--funnelEndpoint="+configs.funnelVIP,
                        ],
                        "ports": [
                        {
                            "containerPort": 9090,
                            "name": "estate-server",
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
                        env: [
                            {
                                "name": "NODE_NAME",
                                "valueFrom": {
                                    "fieldRef": {
                                        "fieldPath": "spec.nodeName",
                                    },
                                },
                            },
                            {
                                "name": "POD_NAME",
                                "valueFrom": {
                                    "fieldRef": {
                                        "fieldPath": "metadata.name",
                                    },
                                },
                            },
                        ],
                    }
                ],
                nodeSelector: {
                } +
                if configs.kingdom == "prd" then {
                    master: "true"
                } else {
                     pool: configs.estate
                },
            },
            metadata: {
                labels: {
                    name: "estate-server",
                    apptype: "server"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "estate-server"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "estate-server"
        },
        name: "estate-server",
        namespace: "sam-system"
    }
} else "SKIP"
