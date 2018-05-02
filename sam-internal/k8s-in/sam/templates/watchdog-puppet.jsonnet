local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
{
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    {
                        hostPath: {
                            path: "/var/lib/puppet/state",
                        },
                        name: "last-run-summary",
                    },
                    {
                        hostPath: {
                            path: "/etc/puppet",
                        },
                        name: "afw-build",
                    },
                    configs.config_volume("watchdog"),
                    configs.cert_volume,
                    configs.maddog_cert_volume,
                ]),
                containers: [
                    {
                        image: samimages.hypersam,
                        command: [
                                     "/sam/watchdog",
                                     "-role=PUPPET",
                                     "-watchdogFrequency=15m",
                                     "-alertThreshold=1000h",
                                     "-emailFrequency=1000h",
                                 ]
#                                 + (if configs.estate == "prd-samdev" then [
 #                                       "--breakwatchdogsdp",
  #                                  ] else [])
                                 + samwdconfig.shared_args
                                 + (if configs.estate == "prd-samtest" then ["-watchDogKind=" + $.kind] else [])
                                 + (if configs.estate == "prd-samtest" then ["-publishToWatchDogCrd=true"] else []),
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
                        volumeMounts: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            {
                                mountPath: "/var/lib/puppet/state",
                                name: "last-run-summary",
                            },
                            {
                                mountPath: "/etc/puppet",
                                name: "afw-build",
                            },
                            configs.config_volume_mount,
                            configs.cert_volume_mount,
                            configs.maddog_cert_volume_mount,
                        ]),
                    },
                ],
            },
            metadata: {
                labels: {
                    app: "watchdog-puppet",
                    apptype: "monitoring",
                    daemonset: "true",
                },
                namespace: "sam-system",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-puppet",
        },
        name: "watchdog-puppet",
    },
}
