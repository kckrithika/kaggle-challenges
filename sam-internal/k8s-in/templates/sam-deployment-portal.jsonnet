local configs = import "config.jsonnet";
if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
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
                          }
                       ],
                       env: [
                          {
                             "name": "KUBECONFIG",
                             "value": configs.configPath
                          }
                       ],
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
                        }
                ],
                nodeSelector: {
                    pool: configs.estate
                }
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
