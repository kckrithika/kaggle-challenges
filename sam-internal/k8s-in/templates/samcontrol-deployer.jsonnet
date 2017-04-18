local configs = import "config.jsonnet";
if configs.kingdom == "prd" || configs.kingdom == "frf" then {
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
                           "--disableSecurityCheck=true",
                           "--tnrpEndpoint="+configs.tnrpArchiveEndpoint,
                           "--k8sapiserver="+configs.k8sapiserver,
                           "--observeMode="+configs.samcontrol_deployer_ObserveMode,
                           "--delay=30s",
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
                             "port": 9099
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
