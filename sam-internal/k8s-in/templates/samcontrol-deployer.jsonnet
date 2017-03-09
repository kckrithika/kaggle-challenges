local configs = import "config.jsonnet";
if configs.estate == "prd-sdc" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "samcontrol-deployer",
                        image: configs.samcontrol_deployer,
                        command: [
                           "/sam/samcontrol-deployer",
                           "--funnelEndpoint="+configs.funnelVIP,
                           "--logtostderr=true",
                           "--tnrpEndpoint="+configs.tnrpArchiveEndpoint,
                           "--k8sapiserver="+configs.k8sapiserver,
                           "--observeMode="+configs.scdObserveMode
                         ],
                         "volumeMounts": [
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
                             "port": 9090
                           },
                           "initialDelaySeconds": 2,
                           "periodSeconds": 10
                        }
                    }
                ],
                volumes: [
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
                    name: "samcontrol-deployer",
                    apptype: "control"
                }
            }
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "samcontrol-deployer"
        },
        name: "samcontrol-deployer"
    }
} else "SKIP"
