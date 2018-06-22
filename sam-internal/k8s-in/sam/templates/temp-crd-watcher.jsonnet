local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.estate == "prd-samtest" then
    {
        kind: "Deployment",
        spec: {
            replicas: 1,
            template: {
                spec: {
                    hostNetwork: true,
                    containers: [
                        {
                            name: "temp-crd-watcher",
                            image: samimages.hypersam,
                            command: configs.filter_empty([
                                "/sam/manifest-watcher",
                                "--funnelEndpoint=" + configs.funnelVIP,
                                "--v=2",
                                "--logtostderr=true",
                                "--config=/config/tempmanifestwatcher.json",
                                configs.sfdchosts_arg,
                            ]),
                            volumeMounts: configs.filter_empty([
                                configs.maddog_cert_volume_mount,
                                configs.sfdchosts_volume_mount,
                                configs.cert_volume_mount,
                                configs.config_volume_mount,
                                configs.kube_config_volume_mount,
                            ]),
                            env: [
                                configs.kube_config_env,
                            ],
                        },
                    ],
                    volumes: configs.filter_empty([
                        configs.maddog_cert_volume,
                        configs.cert_volume,
                        configs.sfdchosts_volume,
                        {
                            hostPath: {
                                path: "/manifests",
                            },
                            name: "sfdc-volume",
                        },
                        configs.config_volume("temp-crd-watcher"),
                        configs.kube_config_volume,
                    ]),
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
            },
            name: "temp-crd-watcher",
        },
    } else "SKIP"
