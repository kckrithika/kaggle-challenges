local configs = import "config.jsonnet";
local wdconfig = import "wdconfig.jsonnet";
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
                        + wdconfig.shared_args
                        + wdconfig.shared_args_certs
                        + (if configs.kingdom == "prd" then [ "-emailFrequency=48h" ] else [ "-emailFrequency=6h" ]),
                       volumeMounts: [
                          wdconfig.cert_volume_mount,
                       ],
                    }
                ],
                volumes: [
                    wdconfig.cert_volume,
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
