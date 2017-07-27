local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

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
                        image: samimages.k8sproxy,
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
                volumes: [
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
                    // In the case of samtest, we deploy only to master so we can assimilate the control-estate
                    // minions to consumer minions and extrapolate the required permissions for those nodes.
                    // When the testing of authorization is done, we can move back to normal (any node of the control-estate)
                    hostname: "kube11"
                } else {
                    pool: configs.estate
                } 
                + if configs.estate == "prd-samtest" then {
                    // In the case of samtest, we deploy only to master so we can assimilate the control-estate
                    // minions to consumer minions and extrapolate the required permissions for those nodes.
                    // When the testing of authorization is done, we can move back to normal (any node of the control-estate)
                    master: "true",
                } else {} 
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
