local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        image: samimages.hypersam,
                        command: [
                            "/bin/bash",
                            "-xe",
                            "/config/ops-adhoc.sh",
                        ],
                        name: "watchdog",
                        resources: {
                            requests: {
                                cpu: "0.5",
                                memory: "300Mi"
                            },
                            limits: {
                                cpu: "0.5",
                                memory: "300Mi"
                            }
                          },
                        volumeMounts: [
                             configs.kube_config_volume_mount,
                             configs.config_volume_mount,
                        ]
                    }
                ],
                volumes: [
                   configs.kube_config_volume,
                   configs.config_volume("watchdog"),
                ]
            },
            metadata: {
                labels: {
                    app: "ops-adhoc",
                    daemonset: "true",
                }
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "ops-adhoc"
        },
        name: "ops-adhoc"
    }
} else
  "SKIP"
