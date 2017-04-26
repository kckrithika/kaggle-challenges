{
  local configs = import "config.jsonnet",
  local wdconfig = import "wdconfig.jsonnet",

    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-etcd-quorum",
                        image: configs.watchdog,
                        command:[
                            "/sam/watchdog",
                            "-role=ETCDQUORUM",
                            "-watchdogFrequency=10s",
                            "-alertThreshold=300s",
                            "-emailFrequency=6h",
                        ]
                        + wdconfig.shared_args
                        + wdconfig.shared_args_certs,
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
