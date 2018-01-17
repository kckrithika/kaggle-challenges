local flowsnakeimage = import "flowsnake_images.jsonnet";
local flowsnakeconfigmapmount = import "flowsnake_configmap_mount.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_minikube then
"SKIP"
else
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
                            "-role=ETCDQUORUM",
                            "-watchdogFrequency=5s",
                            "-alertThreshold=150s",
                            "-emailFrequency=" + flowsnakeconfig.watchdog_email_frequency,
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
                            mountPath: "/config",
                            name: "config",
                          },
                        ] +
                        flowsnakeconfigmapmount.platform_cert_volumeMounts,
                        name: "watchdog-etcd-quorum",
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
                    configMap: {
                      name: "watchdog",
                    },
                    name: "config",
                  },
                ] +
                flowsnakeconfigmapmount.platform_cert_volume,
            },
            metadata: {
                labels: {
                    apptype: "monitoring",
                    name: "watchdog-etcd-quorum",
                },
                namespace: "flowsnake",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-etcd-quorum",
        },
        name: "watchdog-etcd-quorum",
        namespace: "flowsnake",
    },
}
