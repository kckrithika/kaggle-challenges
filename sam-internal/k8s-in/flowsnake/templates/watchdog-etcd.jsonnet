local flowsnakeimage = import "flowsnake_images.jsonnet";
local flowsnakeconfigmapmount = import "flowsnake_configmap_mount.jsonnet";
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
                            "-funnelEndpoint=ajna0-funnel1-0-prd.data.sfdc.net:80",
                            "--config=/config/watchdog.json",
                            "--hostsConfigFile=/sfdchosts/hosts.json",
                            "--snoozedAlarms=etcdChecker=2018/01/22#instance=fs1shared0-flowsnakemaster2-2-prd.eng.sfdc.net",
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
