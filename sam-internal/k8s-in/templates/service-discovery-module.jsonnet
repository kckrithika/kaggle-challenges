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
                        name: "service-discovery-module",
                        image: samimages.hypersam,
                        command:[
                            "/sam/service-discovery-module",
                        ],
                        volumeMounts: [
                          {
                             "mountPath": "/data/certs",
                             "name": "certs"
                          },
                          {
                             "mountPath": "/config",
                             "name": "config"
                          }
                       ],
                       env: [
                          {
                             "name": "namespaceFilter",
                             "value": "user-kdhabalia"
                          },
			  {
			     "name": "zkIP",
			     "value": "10.230.14.31:2181"
			  }
                       ]
                    }
                ],
                volumes: [
                    {
                        hostPath: {
                                path: "/data/certs"
                                },
                                name: "certs"
                        },
                        {
                        hostPath: {
                                path: "/etc/kubernetes"
                                },
                                name: "config"
                        }
                ],
                nodeSelector: {
                    pool: configs.estate
                },
            },
            metadata: {
                labels: {
                    name: "service-discovery-module",
                    apptype: "control"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "service-discovery-module"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "service-discovery-module"
        },
        name: "service-discovery-module",
        namespace: "sam-system"
    }
} else "SKIP"
