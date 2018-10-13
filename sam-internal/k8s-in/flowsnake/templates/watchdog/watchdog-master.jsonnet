local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local watchdog = import "watchdog.jsonnet";
local configs = import "config.jsonnet";
local flag_fs_metric_labels = std.objectHas(flowsnake_images.feature_flags, "fs_metric_labels");
local flag_fs_matchlabels = std.objectHas(flowsnake_images.feature_flags, "fs_matchlabels");

if !watchdog.watchdog_enabled then
"SKIP"
else
configs.daemonSetBase("flowsnake") {
    local label_node = self.spec.template.metadata.labels,
    spec+: {
        [if flag_fs_matchlabels then "selector"]: {
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
                            "-role=MASTER",
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
                nodeSelector: {
                    master: "true",
                },
            },
            metadata: {
                labels: {
                    app: "watchdog-master",
                    apptype: "monitoring",
                    daemonset: "true",
                } + if flag_fs_metric_labels then {
                    flowsnakeOwner: "dva-transform",
                    flowsnakeRole: "WatchdogMaster",
                } else {},
            },
        },
    },
    metadata: {
        labels: {
            name: "watchdog-master",
        },
        name: "watchdog-master",
        namespace: "flowsnake",
    },
}
