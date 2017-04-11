local configs = import "config.jsonnet";

if configs.kingdom == "prd" then {
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
                            "-timeout=2s",
                            "-funnelEndpoint="+configs.funnelVIP,
                            "-rcImtEndpoint="+configs.rcImtEndpoint,
                            "-smtpServer="+configs.smtpServer,
                            "-sender="+configs.watchdog_emailsender,
                            "-recipient="+configs.watchdog_emailrec,
                            "-tlsEnabled="+configs.tlsEnabled,
                            "-caFile="+configs.caFile,
                            "-keyFile="+configs.keyFile,
                            "-certFile="+configs.certFile,
                        ],
                       volumeMounts: [
                          {
                             "mountPath": "/data/certs",
                             "name": "certs"
                          },
                       ],
                    }
                ],
                volumes: [
                    {
                        hostPath: {
                                path: "/data/certs"
                                },
                                name: "certs"
                        },
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
} else "SKIP"
