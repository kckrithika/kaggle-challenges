local configs = import "config.jsonnet";
local flowsnakeimage = import "flowsnake_images.jsonnet";
{
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        image: flowsnakeimage.watchdog,
                        command: [
                            "/sam/watchdog",
                            "-role=NODE",
                            "-watchdogFrequency=60s",
                            "-alertThreshold=150s",
                            "-emailFrequency=5m",
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
                        volumeMounts: [
                            {
                                mountPath: "/data/certs",
                                name: "certs",
                            },
                            {
                                mountPath: "/config",
                                name: "config",
                            },
                            {
                                mountPath: "/data/hosts",
                                name: "hosts",
                            },
                        ],
                        name: "watchdog-node",
                        env: [
                            {
                                name: "KUBECONFIG",
                                value: "/config/kubeconfig",
                            },
                        ],
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
                        hostPath: {
                            path: "/etc/kubernetes",
                        },
                        name: "config",
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
                    apptype: "monitoring",
                    name: "watchdog-node",
                },
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-node",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-node",
        },
        name: "watchdog-node",
        namespace: "flowsnake",
    },
}
