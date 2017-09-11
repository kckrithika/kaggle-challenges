local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

if configs.kingdom == "NOTDEPLOYED" then {
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
                        volumeMounts: configs.cert_volume_mounts + [
                          configs.cert_volume_mount,
                          configs.kube_config_volume_mount,
                       ],
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
                volumes: configs.cert_volumes + [
                    configs.cert_volume,
                    configs.kube_config_volume,
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
