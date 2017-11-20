local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

if configs.estate == "prd-samtest" then
{
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "temp-manifest-watcher",
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
                      volumeMounts: configs.filter_empty([
                          configs.maddog_cert_volume_mount,
                          configs.sfdchosts_volume_mount,
                          configs.cert_volume_mount,
                          configs.config_volume_mount,
                        ]),
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
                    configs.config_volume("temp-manifest-watcher"),
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
                    name: "temp-manifest-watcher",
                    apptype: "control",
                },
                namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "temp-manifest-watcher",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "temp-manifest-watcher",
        },
        name: "temp-manifest-watcher",
    },
} else "SKIP"
