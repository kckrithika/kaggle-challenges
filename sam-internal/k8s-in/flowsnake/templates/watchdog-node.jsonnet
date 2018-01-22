local flowsnakeimage = import "flowsnake_images.jsonnet";
local flowsnakeconfigmapmount = import "flowsnake_configmap_mount.jsonnet";
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
                            "-funnelEndpoint=ajna0-funnel1-0-prd.data.sfdc.net:80",
                            "--config=/config/watchdog.json",
                            "--hostsConfigFile=/sfdchosts/hosts.json",
                        ],
                        volumeMounts: [
                          {
                            mountPath: "/sfdchosts",
                            name: "sfdchosts",
                          },
                          {
                            mountPath: "/hostproc",
                            name: "procfs-volume",
                          },
                          {
                            mountPath: "/config",
                            name: "config",
                          },
                        ] +
                        flowsnakeconfigmapmount.cert_volumeMounts,
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
                    configMap: {
                      name: "sfdchosts",
                    },
                    name: "sfdchosts",
                  },
                  {
                    hostPath: {
                      path: "/proc",
                    },
                    name: "procfs-volume",
                  },
                  {
                    configMap: {
                      name: "watchdog",
                    },
                    name: "config",
                  },
                ] +
                flowsnakeconfigmapmount.cert_volume,
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
