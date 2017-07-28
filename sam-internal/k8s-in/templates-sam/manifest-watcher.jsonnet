local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

{

    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "manifest-watcher",
                        image: samimages.hypersam,
                        command: [
                           "/sam/manifest-watcher",
                           "--funnelEndpoint="+configs.funnelVIP,
                           "--v=2",
                           "--logtostderr=true",
                           "--disableCertsCheck=true",
                           "--tnrpArchiveEndpoint="+configs.tnrpArchiveEndpoint,
                           "--tlsEnabled=true",
                           "--caFile="+configs.caFile,
                           "--keyFile="+configs.keyFile,
                           "--certFile="+configs.certFile,
                           "--syntheticEndpoint=http://$(WATCHDOG_SYNTHETIC_SERVICE_SERVICE_HOST):9090/tnrp/content_repo/0/archive"
                         ],
                      "volumeMounts": [
                         {
                            "mountPath": "/data/certs",
                            "name": "certs"
                         }
                      ]
                      + if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then [
                          {
                            "mountPath": "/config",
                            "name": "config"
                          }
                       ] else [],
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
                ] +
                if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then [
                    {
                        name: "config",
                        configMap: {
                          name: "manifest-watcher",
                        }
                    }
                ] else [],
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
