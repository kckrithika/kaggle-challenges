local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
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
                        name: "watchdog-etcd-quorum",
                        image: samimages.hypersam,
                        command:[
                            "/sam/watchdog",
                            "-role=ETCDQUORUM",
                            "-watchdogFrequency=10s",
                            "-alertThreshold=300s",
                        ]
                        + samwdconfig.shared_args
                        + samwdconfig.shared_args_certs
                        + (if configs.kingdom == "prd" then [ "-emailFrequency=48h" ] else [ "-emailFrequency=6h" ]),
                        # Please add all new flags and snooze instances to ../configs-sam/watchdog-config.jsonnet
                       volumeMounts: [
                          configs.cert_volume_mount,
                          configs.config_volume_mount,
                       ],
                    }
                ],
                volumes: [
                    configs.cert_volume,
                    configs.config_volume("watchdog"),
                ],
                nodeSelector: {
                    pool: configs.estate
                }
            },
            metadata: {
                labels: {
                    name: "watchdog-etcd-quorum",
                    apptype: "monitoring"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "watchdog-etcd-quorum"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-etcd-quorum"
        },
        name: "watchdog-etcd-quorum"
    }
}
