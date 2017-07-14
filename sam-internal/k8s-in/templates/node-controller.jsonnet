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
                        name: "node-controller",
                        image: samimages.node_controller,
                        command:["/sam/node-controller"],
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
                             "name": "KUBECONFIG",
                             "value": configs.configPath
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
