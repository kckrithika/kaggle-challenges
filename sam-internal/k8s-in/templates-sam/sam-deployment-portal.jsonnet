local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";
if configs.kingdom == "prd" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sam-deployment-portal",
                        image: samimages.hypersam,
                        command:[
                           "/sam/sam-deployment-portal",
                        ],
                       volumeMounts: [
                          configs.cert_volume_mount,
                          configs.kube_config_volume_mount,
                          { 
                             "mountPath": "/var/token",
                             "name": "token",
                             "readOnly" : true
                          } 
                       ],
                       env: [
                          configs.kube_config_env,
                       ],
                       livenessProbe: {
                           initialDelaySeconds: 15,
                           httpGet: {
                               path: "/",
                               port: 64121
                           },
                           timeoutSeconds: 10
                       },
                       workingDir: "/sam"
                    }
                ],
                volumes: [
                    configs.cert_volume,
                    configs.kube_config_volume,
                    {
                        secret: {
                              secretName: "git-token"
                        },
                        name: "token"
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
                } else {}
            },
            metadata: {
                labels: {
                    name: "sam-deployment-portal",
                    apptype: "control"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "sam-deployment-portal"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sam-deployment-portal"
        },
        name: "sam-deployment-portal"
    }
} else "SKIP"
