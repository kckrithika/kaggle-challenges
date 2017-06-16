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
                            "-role=COMMON",
                            "-watchdogFrequency=5s",
                            "-alertThreshold=300s",
                        ]
                        + samwdconfig.shared_args
                        + (if configs.kingdom == "prd" then [ "-emailFrequency=72h" ] else [ "-emailFrequency=24h" ])
                        + [ "-snoozedAlarms=kubeletChecker=2017/06/15&kubeProxyChecker=2017/06/15" ],
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
                             {
                                "mountPath": "/hostproc",
                                "name": "procfs-volume"
                             }
                        ]
                    }
                ],
                volumes: [
                   {
                      "hostPath": {
                         "path": "/proc"
                      },
                      "name": "procfs-volume"
                   }
                ]
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
