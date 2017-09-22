local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

if configs.kingdom == "prd" || configs.kingdom == "phx" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                containers: [
                    {
                        name: "node-controller",
                        image: samimages.hypersam,
                        command:[
                            "/sam/node-controller",
                           "--funnelEndpoint="+configs.funnelVIP,
                        ],
                        volumeMounts: configs.filter_empty([
                          configs.maddog_cert_volume_mount,
                          configs.cert_volume_mount,
                          configs.kube_config_volume_mount,
                       ]),
                       env: [
                          {
                              "name": "NODE_NAME",
                              "valueFrom": {
                                  "fieldRef": {
                                      "fieldPath": "spec.nodeName",
                                  },
                              },
                          },
                          configs.kube_config_env,
                       ]
                    }
                ],
                volumes: configs.filter_empty([
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                ]),
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
                    name: "node-controller",
                    apptype: "control"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "node-controller"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "node-controller"
        },
        name: "node-controller",
        namespace: "sam-system"
    }
} else "SKIP"
