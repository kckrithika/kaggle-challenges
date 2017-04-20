local configs = import "config.jsonnet";
local wdconfig = import "wdconfig.jsonnet";

{
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        image: configs.watchdog,
                        command: [
                            "/sam/watchdog",
                            "-role=MASTER",
                            "-watchdogFrequency=5s",
                            "-alertThreshold=150s",
                            "-emailFrequency=12h",
                        ]
                        + wdconfig.shared_args
                        + wdconfig.shared_args_certs
                        + if configs.estate == "prd-samtest" then [ "-snoozedAlarms=kubeApiChecker=2017/04/25" ] else  [],
                    "volumeMounts": [
                        wdconfig.cert_volume_mount,
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
                        }
                    }
                ],
                volumes: [
                    wdconfig.cert_volume,
                ],
                nodeSelector: {
                    master: "true",
                }
            },
            metadata: {
                labels: {
                    app: "watchdog-master",
                    apptype: "monitoring",
                    daemonset: "true",
                }
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-master"
        },
        name: "watchdog-master"
    }
}
