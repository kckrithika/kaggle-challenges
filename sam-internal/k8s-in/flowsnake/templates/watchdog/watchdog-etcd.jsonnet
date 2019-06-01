local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local estate = std.extVar("estate");
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local watchdog = import "watchdog.jsonnet";
local configs = import "config.jsonnet";


if !watchdog.watchdog_enabled then
"SKIP"
else
configs.daemonSetBase("flowsnake") {
    local label_node = self.spec.template.metadata.labels,
    spec+: {
        selector: {
            matchLabels: {
                app: label_node.app,
                apptype: label_node.apptype,
            }
        },
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        image: flowsnake_images.watchdog,
                        command: [
                            "/sam/watchdog",
                            "-role=ETCD",
                            "-watchdogFrequency=5s",
                            "-alertThreshold=150s",
                            "-emailFrequency=" + watchdog.watchdog_email_frequency,
                            "-timeout=2s",
                            "-funnelEndpoint=" + flowsnakeconfig.funnel_vip_and_port,
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
                          {
                            mountPath: "/var/tmp",
                            name: "etcd-health-info",
                          },
                        ] +
                        certs_and_kubeconfig.platform_cert_volumeMounts,
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
                    configMap: {
                      name: "watchdog",
                    },
                    name: "config",
                  },
                  {
                    hostPath: {
                      path: "/var/tmp",
                    },
                    name: "etcd-health-info",
                  },
                ] +
                certs_and_kubeconfig.platform_cert_volume,
                nodeSelector: {
                    etcd_installed: "true",
                },
            },
            metadata: {
                labels: {
                    app: "watchdog-etcd",
                    apptype: "monitoring",
                    daemonset: "true",
                    flowsnakeOwner: "dva-transform",
                    flowsnakeRole: "WatchdogEtcd",
                },
            },
        },
    },
    metadata: {
        labels: {
            name: "watchdog-etcd",
        },
        name: "watchdog-etcd",
        namespace: "flowsnake",
    },
}
