local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

if configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.estate == "prd-sdc" || configs.estate == "prd-samtest" || configs.estate == "prd-sam_storage" then {

    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "k8sproxy",
                        image: samimages.k8sproxy,
                        args:[
                           "-f ",
                           "/etc/haproxy/haproxy.cfg"
                        ],
                        volumeMounts: configs.cert_volume_mounts + [
                            {
                                name: "sfdc-volume",
                                mountPath: "/etc/certs"
                            }
                        ],
                        "ports": [
                        {
                            "containerPort": 5000,
                            "name": "k8sproxy",
                        }
                        ],
                      livenessProbe: {
                           initialDelaySeconds: 15,
                           httpGet: {
                               path: "/",
                               port: 5000
                           },
                           timeoutSeconds: 10
                        },
                    }
                ],
                volumes: configs.cert_volumes + [
                    {
                        hostPath: {
                            path: "/data/certs"
                        },
                        name: "sfdc-volume"
                    }
                ],
                nodeSelector: {
                }
		        + if configs.estate == "prd-sam" then {
                    hostname: "kube11"
                } else {}
                + if configs.kingdom == "prd" then {
                    master: "true",
                } else {
                    pool: configs.estate
                }
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
