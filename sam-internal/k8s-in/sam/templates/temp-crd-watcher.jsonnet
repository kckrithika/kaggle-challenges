local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.estate == "prd-samtest" then
    {
        kind: "Deployment",
        spec: {
            replicas: 1,
            template: {
                spec: configs.specWithKubeConfigAndMadDog {
                    hostNetwork: true,
                    containers: [
                        configs.containerWithKubeConfigAndMadDog {
                            name: "temp-crd-watcher",
                            image: samimages.hypersam,
                            command: configs.filter_empty([
                                "/sam/manifest-watcher",
                                "--funnelEndpoint=" + configs.funnelVIP,
                                "--v=2",
                                "--logtostderr=true",
                                "--config=/config/tempmanifestwatcher.json",
                                "--syntheticEndpoint=http://$(WATCHDOG_SYNTHETIC_SERVICE_SERVICE_HOST):9090/tnrp/content_repo/0/archive",
                                configs.sfdchosts_arg,
                            ]),
                            volumeMounts+: [
                                configs.sfdchosts_volume_mount,
                                configs.config_volume_mount,
                                configs.cert_volume_mount,
                            ],
                        },
                    ],
                    volumes+: [
                        configs.cert_volume,
                        configs.sfdchosts_volume,
                        {
                            hostPath: {
                                path: "/manifests",
                            },
                            name: "sfdc-volume",
                        },
                        configs.config_volume("temp-crd-watcher"),
                    ],
                    nodeSelector: {
                                  } +
                                  if configs.kingdom == "prd" then {
                                      master: "true",
                                  } else {
                                      pool: configs.estate,
                                  },
                },
                metadata: {
                    labels: {
                        name: "temp-crd-watcher",
                        apptype: "control",
                    } + configs.ownerLabel.sam,
                    namespace: "sam-system",
                },
            },
            selector: {
                matchLabels: {
                    name: "temp-crd-watcher",
                },
            },
        },
        apiVersion: "extensions/v1beta1",
        metadata: {
            labels: {
                name: "temp-crd-watcher",
            } + configs.ownerLabel.sam,
            name: "temp-crd-watcher",
        },
    } else "SKIP"
