local configs = import "config.jsonnet";
local flowsnakeimage = import "flowsnake_images.jsonnet";
{
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        image: flowsnakeimage.watchdog,
                        command: [
                            "/sam/watchdog",
                            "-role=ETCD",
                            "-watchdogFrequency=5s",
                            "-alertThreshold=150s",
                            "-emailFrequency=3m",
                            "-timeout=2s",
                            "-funnelEndpoint=" + configs.funnelVIP,
                            "-rcImtEndpoint=" + configs.rcImtEndpoint,
                            "-smtpServer=" + configs.smtpServer,
                            "-sender=vgiridaran@salesforce.com",
                            "-recipient=vgiridaran@salesforce.com",
                            "-email-subject-prefix=FLOWSNAKEWD",
                            "-hostsConfigFile=/data/hosts/hosts.json",
                            "-metricsService=flowsnake",
                            "-tlsEnabled=true",
                            "-caFile=/data/certs/ca.crt",
                            "-keyFile=/data/certs/hostcert.key",
                            "-certFile=/data/certs/hostcert.crt",
                        ],
                        volumeMounts: [
                            {
                                mountPath: "/data/certs",
                                name: "certs",
                            },
                            {
                                mountPath: "/data/hosts",
                                name: "hosts",
                            },
                        ],
                        name: "watchdog",
                        resources: {
                            requests: {
                                cpu: "0.5",
                                memory: "300Mi",
                            },
                            limits: {
                                cpu: "0.5",
                                memory: "300Mi",
                            },
                        },
                    },
                ],
                volumes: [
                    {
                        hostPath: {
                            path: "/data/certs",
                        },
                        name: "certs",
                    },
                    {
                        configMap: {
                            name: "sfdchosts",
                        },
                        name: "hosts",
                    },
                ],
                nodeSelector: {
                    etcd_installed: "true",
                },
            },
            metadata: {
                labels: {
                    app: "watchdog-etcd",
                    apptype: "monitoring",
                    daemonset: "true",
                },
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-etcd",
        },
        name: "watchdog-etcd",
        namespace: "flowsnake",
    },
}
