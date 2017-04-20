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
                            "-role=COMMON",
                            "-watchdogFrequency=5s",
                            "-alertThreshold=150s",
                            "-emailFrequency=24h",
                        ]
                        + wdconfig.shared_args
                        + [
                            "-snoozedAlarms=bridgeChecker=2017/04/25",
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
            },
            metadata: {
                labels: {
                    app: "watchdog-common",
                    apptype: "monitoring",
                    daemonset: "true",
                }
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-common"
        },
        name: "watchdog-common"
    }
}
