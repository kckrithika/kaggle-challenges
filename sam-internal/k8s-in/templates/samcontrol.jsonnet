{
local configs = import "config.jsonnet",

    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sam-controller",
                        image: configs.controller,
                        command:[
                           "/sam/sam-controller",
                           "--debug=true",
                           "--dockerregistry="+configs.registry,
                           "--funnelEndpoint="+configs.funnelVIP,
                           "--v=3",
                           "--logtostderr=true",
                           "--k8sapiserver="+configs.k8sapiserver,
                           "--tlsEnabled="+configs.tlsEnabled,
                           "--caFile="+configs.caFile,
                           "--keyFile="+configs.keyFile,
                           "--certFile="+configs.certFile,
                           "--checkImageExistsFlag="+configs.checkImageExistsFlag,
                           ]
                           + if configs.estate == "prd-samdev" then [ "-volPermissionInitContainerImage="+configs.controller ] else [],
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
                }
            },
            metadata: {
                labels: {
                    name: "samcontrol",
                    apptype: "control"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "samcontrol"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "samcontrol"
        },
        name: "samcontrol"
    }
}
