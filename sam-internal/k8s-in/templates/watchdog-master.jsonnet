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
                            "-role=MASTER",
                            "-watchdogFrequency=5s",
                            "-alertThreshold=150s",
                        ]
                        + samwdconfig.shared_args
                        + samwdconfig.shared_args_certs
                        # [thargrove] 2017-05-05 shared0-samtestkubeapi2-1-prd.eng.sfdc.net is down
                        + (if configs.estate == "prd-samtest" then [ "-snoozedAlarms=kubeApiChecker=2017/06/02" ] else  [])
                        + (if configs.kingdom == "prd" then [ "-emailFrequency=48h" ] else [ "-emailFrequency=12h" ]),
                    "volumeMounts": [
                        samwdconfig.cert_volume_mount,
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
                    samwdconfig.cert_volume,
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
