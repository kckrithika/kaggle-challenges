local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

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
                        command: configs.filter_empty([
                           "/sam/manifest-watcher",
                           "--funnelEndpoint=" + configs.funnelVIP,
                           "--v=2",
                           "--logtostderr=true",
                           "--config=/config/manifestwatcher.json",
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
                    configs.config_volume("manifest-watcher"),
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
                    name: "manifest-watcher",
                    apptype: "control",
                },
                namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "manifest-watcher",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "manifest-watcher",
        },
        name: "manifest-watcher",
    },
}
