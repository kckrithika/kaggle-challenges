local configs = import "config.jsonnet";
local flowsnakeimage = import "flowsnake_images.jsonnet";
{
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                containers: [
                    {
                        image: flowsnakeimage.watchdog,
                        command: [
                            "/sam/watchdog",
                            "-role=COMMON",
                            "-watchdogFrequency=5s",
                            "-alertThreshold=20m",
                            "-emailFrequency=6m",
                            "-timeout=2s",
                            "-funnelEndpoint=" + configs.funnelVIP,
                            "-rcImtEndpoint=" + configs.rcImtEndpoint,
                            "-smtpServer=" + configs.smtpServer,
                            "-sender=vgiridaran@salesforce.com",
                            "-recipient=vgiridaran@salesforce.com",
                            "-email-subject-prefix=FLOWSNAKEWD",
                            "-hostsConfigFile=/data/hosts/hosts.json",
                            "-metricsService=flowsnake",
                        ],
                        name: "watchdog",
                        resources: {
                            limits: {
                                cpu: "0.5",
                                memory: "300Mi",
                            },
                            requests: {
                                cpu: "0.5",
                                memory: "300Mi",
                            },
                        },
                        volumeMounts: [
                            {
                                mountPath: "/hostproc",
                                name: "procfs-volume",
                            },
                            {
                                mountPath: "/data/hosts",
                                name: "hosts",
                            },
                        ],
                    },
                ],
                hostNetwork: true,
                volumes: [
                    {
                        hostPath: {
                            path: "/proc",
                        },
                        name: "procfs-volume",
                    },
                    {
                        configMap: {
                            name: "sfdchosts",
                        },
                        name: "hosts",
                    },
                ],
            },
            metadata: {
                labels: {
                    app: "watchdog-common",
                    apptype: "monitoring",
                    daemonset: "true",
                },
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-common",
        },
        name: "watchdog-common",
        namespace: "flowsnake",
    },
}
