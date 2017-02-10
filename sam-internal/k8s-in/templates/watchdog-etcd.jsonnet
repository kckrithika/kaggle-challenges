{
local configs = import "config.jsonnet",

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
                            "-role=ETCD",
                            "-watchdogFrequency=5s",
                            "-alertThreshold=150s",
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
                    "volumeMounts": [
                        {
                            "mountPath": "/data/certs",
                            "name": "certs"
                        }
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
                    {
                        hostPath: {
                                   path: "/data/certs"
                                  },
                                  name: "certs"
                    }
                ],
                nodeSelector: {
                    etcd_installed: "true",
                }
            }, 
            metadata: {
                labels: {
                    app: "watchdog-etcd", 
                    apptype: "monitoring",
                    daemonset: "true",
                }
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
