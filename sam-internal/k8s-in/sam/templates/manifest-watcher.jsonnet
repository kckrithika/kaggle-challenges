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
                           "--config=/config/manifestwatcher.json",
                           "--syntheticEndpoint=http://$(WATCHDOG_SYNTHETIC_SERVICE_SERVICE_HOST):9090/tnrp/content_repo/0/archive"
                         ],
                      "volumeMounts": configs.cert_volume_mounts + [
                         configs.cert_volume_mount,
                         configs.config_volume_mount,
                       ],
                    }
                ],
                volumes: configs.cert_volumes + [
                    configs.cert_volume,
                     {
                        hostPath: {
                            path: "/manifests"
                        },
                        name: "sfdc-volume"
                    },
                    configs.config_volume("manifest-watcher"),
                ],
                nodeSelector: {
                    pool: configs.estate
                } +
                if configs.kingdom == "prd" then {
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
