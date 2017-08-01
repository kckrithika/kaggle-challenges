local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

if configs.estate == "prd-sam" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
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
			    "-namespaceFilter=user-kdhabalia,caas",
			    "-zkIP="+configs.zookeeperip,
                        ],
			env: [
                          {
                             "name": "KUBECONFIG",
                             "value": configs.configPath
                          }
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
