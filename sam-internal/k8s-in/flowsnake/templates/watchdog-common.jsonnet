local flowsnakeimage = import "flowsnake_images.jsonnet";
local flowsnakeconfigmapmount = import "flowsnake_configmap_mount.jsonnet";
local estate = std.extVar("estate");
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
                            "-timeout=2s",
                            "-funnelEndpoint=ajna0-funnel1-0-prd.data.sfdc.net:80",
                            "--config=/config/watchdog.json",
                            "--hostsConfigFile=/sfdchosts/hosts.json",
                            "-emailFrequency=" + (if estate == "prd-data-flowsnake_test" then "72h" else "6m"),
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
                    },
                ],
                hostNetwork: true,
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
