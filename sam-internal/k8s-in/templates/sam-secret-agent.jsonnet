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
                        name: "sam-secret-agent",
                        image: samimages.hypersam,
                        command: [
                           "/sam/sam-secret-agent",
                           "--funnelEndpoint="+configs.funnelVIP,
                           "--logtostderr=true",
                           "--disableSecurityCheck=true",
                           "--tnrpEndpoint="+configs.tnrpArchiveEndpoint,
                           "--k8sapiserver="+configs.apiserver,
                           "--observeMode="+configs.sam_secret_agent_ObserveMode,
                           "--delay=300s",
                           "--keyfile=/data/certs/hostcert.key",
                           "--certfile=/data/certs/hostcert.crt",
                           "--cafile=/data/certs/ca.crt"
                         ],
                         "volumeMounts": [
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
                         livenessProbe: {
                           "httpGet": {
                             "path": "/",
                             "port": 9098
                           },
                           "initialDelaySeconds": 2,
                           "periodSeconds": 10,
                           "timeoutSeconds": 10
                        }
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
                    name: "sam-secret-agent",
                    apptype: "control"
                }
            }
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sam-secret-agent"
        },
        name: "sam-secret-agent"
    }
} else "SKIP"
