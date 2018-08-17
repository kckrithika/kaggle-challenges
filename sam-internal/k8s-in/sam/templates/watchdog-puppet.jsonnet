local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
{
    kind: "DaemonSet",
    spec: {
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                volumes+: [
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
                ],
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        image: samimages.hypersam,
                        command: [
                                     "/sam/watchdog",
                                     "-role=PUPPET",
                                     "-watchdogFrequency=15m",
                                     "-alertThreshold=1000h",
                                     "-emailFrequency=1000h",
                                     "-watchDogKind=" + $.kind,
                                 ]
#                                 + (if configs.estate == "prd-samdev" then [
 #                                       "--breakwatchdogsdp",
  #                                  ] else [])
                                 + samwdconfig.shared_args,
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
                        volumeMounts+: [
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
                        ],
                    },
                ],
            },
            metadata: {
                labels: {
                    app: "watchdog-puppet",
                    apptype: "monitoring",
                    daemonset: "true",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
        updateStrategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: "25%",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-puppet",
        } + configs.ownerLabel.sam,
        name: "watchdog-puppet",
    },
}
