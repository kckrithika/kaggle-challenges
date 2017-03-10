local configs = import "config.jsonnet";
if configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.estate == "prd-sdc" || configs.estate == "prd-samtest" then {

    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "k8sproxy",
                        image: configs.k8sproxy,
                        args:[
                           "-f ",
                           "/etc/haproxy/haproxy.cfg"
                        ],
                        volumeMounts: [
                            {
                                name: "sfdc-volume",
                                mountPath: "/etc/certs"
                            }
                        ],
                        "ports": [
                        {
                            "containerPort": 8080,
                            "name": "k8sproxy",
                        }
                        ],
                      livenessProbe: {
                           initialDelaySeconds: 15,
                           httpGet: {
                               path: "/",
                               port: 8080
                           },
                           timeoutSeconds: 10
                        },
                    }
                ],
                volumes: [
                    {
                        hostPath: {
                            path: "/data/certs"
                        },
                        name: "sfdc-volume"
                    }
                ],
                nodeSelector: {
                    pool: configs.estate
                },
            },
            metadata: {
                labels: {
                    name: "k8sproxy",
                    apptype: "proxy"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "k8sproxy"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "k8sproxy"
        },
        name: "k8sproxy",
        namespace: "sam-system"
    }
} else "SKIP"
