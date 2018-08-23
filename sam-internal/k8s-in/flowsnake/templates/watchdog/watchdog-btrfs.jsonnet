local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local configs = import "config.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local watchdog = import "watchdog.jsonnet";
if !watchdog.watchdog_enabled || !std.objectHas(flowsnake_images.feature_flags, "btrfs_watchdog_hard_reset") then
"SKIP"
else
{
    apiVersion: "extensions/v1beta1",
    metadata: {
        name: "watchdog-btrfs",
        namespace: "flowsnake",
    },
    kind: "DaemonSet",
    spec: {
        template: {
            metadata: {
                labels: {
                    app: "watchdog-btrfs",
                    apptype: "monitoring"
                },
            },
            spec: {
                restartPolicy: "Always",
                hostNetwork: true,
                containers: [
                    {
                        image: flowsnake_images.watchdog,
                        imagePullPolicy: flowsnakeconfig.default_image_pull_policy,
                        command: [
                            "/sam/watchdog",
                            "-role=CLI",
                            "-cliCheckerCommandTarget=BtrfsHung",
                            "-emailFrequency=" + watchdog.watchdog_email_frequency,
                            "-timeout=2s",
                            "-funnelEndpoint=" + flowsnakeconfig.funnel_vip_and_port,
                            "--config=/config/watchdog.json",
                            "--hostsConfigFile=/sfdchosts/hosts.json",
                            "-watchdogFrequency=10s",
                            "-alertThreshold=45m",
                            "-cliCheckerTimeout=5m",
                        ],
                        name: "watchdog-btrfs",
                        resources: {
                            requests: {
                                cpu: "0.1",
                                memory: "100Mi",
                            },
                            limits: {
                                cpu: "0.1",
                                memory: "100Mi",
                            },
                        },
                        volumeMounts: [
                            {
                                name: "host-proc",
                                mountPath: "/host-proc",
                                readOnly: false
                            },
                            {
                                name: "check-btrfs-sh",
                                mountPath: "/var/run/check-btrfs",
                                readOnly: true,
                            },
                            configs.config_volume_mount,
                            watchdog.sfdchosts_volume_mount
                        ],
                    },
                ],
                volumes: [
                    {
                        name: "host-proc",
                        hostPath: {
                            path: "/proc",
                        }
                    },
                    {
                      configMap: {
                        name: "check-btrfs-sh",
                      },
                      name: "check-btrfs-sh",
                    },
                    {
                      configMap: {
                        name: "watchdog",
                      },
                      name: "config",
                    },
                    watchdog.sfdchosts_volume,
                ],
            },
        },
    }
}
