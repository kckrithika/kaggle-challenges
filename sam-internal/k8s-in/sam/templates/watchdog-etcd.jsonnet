local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = import "samimages.jsonnet";
{
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        image: samimages.hypersam,
                        command: [
                            "/sam/watchdog",
                            "-role=ETCD",
                            "-watchdogFrequency=5s",
                            "-alertThreshold=150s",
                        ]
                        + samwdconfig.shared_args
                        + (if configs.kingdom == "prd" then [ "-emailFrequency=48h" ] else [ "-emailFrequency=12h" ]),
                        # Please add all new flags and snooze instances to ../configs-sam/watchdog-config.jsonnet
                    volumeMounts: configs.filter_empty([
                        configs.maddog_cert_volume_mount,
                        configs.cert_volume_mount,
                        configs.config_volume_mount,
                    ]),
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
                        }
                    }
                ],
                volumes: configs.filter_empty([
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.config_volume("watchdog"),
                ]),
                nodeSelector: {
                    etcd_installed: "true",
                }
            },
            metadata: {
                labels: {
                    app: "watchdog-etcd",
                    apptype: "monitoring",
                    daemonset: "true",
                },
               "namespace": "sam-system"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-etcd"
        },
        name: "watchdog-etcd"
    }
}
