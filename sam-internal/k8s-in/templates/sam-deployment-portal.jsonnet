local configs = import "config.jsonnet";
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
                        image: configs.sam_deployment_portal,
                        command:[
                           "/sam/sam-deployment-portal",
                        ],
                       volumeMounts: [
                          {
                             "mountPath": "/data/certs",
                             "name": "certs"
                          },
                          {
                             "mountPath": "/config",
                             "name": "config"
                          },
                          { 
                             "mountPath": "/var/token",
                             "name": "token",
                             "readOnly" : true
                          } 
                       ],
                       env: [
                          {
                             "name": "KUBECONFIG",
                             "value": configs.configPath
                          }
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
                        },
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
