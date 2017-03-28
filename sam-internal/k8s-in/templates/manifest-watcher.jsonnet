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
                        name: "manifest-watcher",
                        image: configs.manifest_watcher,
                        command: [
                           "/sam/manifest-watcher",
                           "--funnelEndpoint="+configs.funnelVIP,
                           "--v=2",
                           "--logtostderr=true",
                           "--disableCertsCheck=true",
                           "--tnrpArchiveEndpoint="+configs.tnrpArchiveEndpoint,
                           "--tlsEnabled="+configs.tlsEnabled,
                           "--caFile="+configs.caFile,
                           "--keyFile="+configs.keyFile,
                           "--certFile="+configs.certFile,
                         ],
                      "volumeMounts": [
                         {
                            "mountPath": "/data/certs",
                            "name": "certs"
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
                            path: "/manifests"
                        },
                        name: "sfdc-volume"
                    }

                ],
                nodeSelector: {
                    pool: configs.estate
                } +
                if configs.estate == "prd-samtest" then {
                    // In the case of samtest, we deploy only to master so we can assimilate the control-estate
                    // minions to consumer minions and extrapolate the required permissions for those nodes.
                    // When the testing of authorization is done, we can move back to normal (any node of the control-estate)
                    master: true
                } else {}
            },
            metadata: {
                labels: {
                    name: "manifest-watcher",
                    apptype: "control"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "manifest-watcher"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "manifest-watcher"
        },
        name: "manifest-watcher"
    }
}
