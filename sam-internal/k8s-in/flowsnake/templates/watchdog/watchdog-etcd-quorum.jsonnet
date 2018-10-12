local flowsnakeimage = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local watchdog = import "watchdog.jsonnet";
local configs = import "config.jsonnet";
local flag_fs_metric_labels = std.objectHas(flowsnakeimage.feature_flags, "fs_metric_labels");

if !watchdog.watchdog_enabled then
"SKIP"
else
configs.deploymentBase("flowsnake") {
    local label_node = self.spec.template.metadata.labels,
    spec+: {
        replicas: 1,
        selector: {
            matchLabels: {
                name: label_node.name,
                apptype: label_node.apptype,
            },
        },
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
                        ] +
                        certs_and_kubeconfig.platform_cert_volumeMounts,
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
                certs_and_kubeconfig.platform_cert_volume,
            },
            metadata: {
                labels: {
                    apptype: "monitoring",
                    name: "watchdog-etcd-quorum",
                } + if flag_fs_metric_labels then {
                    flowsnakeOwner: "dva-transform",
                    flowsnakeRole: "WatchdogEtcdQuorum",
                } else {},
                namespace: "flowsnake",
            },
        },
    },
    metadata: {
        labels: {
            name: "watchdog-etcd-quorum",
        },
        name: "watchdog-etcd-quorum",
        namespace: "flowsnake",
    },
}
