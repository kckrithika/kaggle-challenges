local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = import "samimages.jsonnet";
if configs.estate == "prd-samdev" || configs.estate == "prd-samtest" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-kuberesources",
                        image: samimages.hypersam,
                        command:[
                            "/sam/watchdog",
                            "-role=KUBERESOURCES",
                            "-watchdogFrequency=60s",
                            "-alertThreshold=1h",
                            "-maxUptimeSampleSize=5",
                            "-emailAdditionalRecipients=true",
                            # We dont want to report on broken hairpin pods, since hairpin already alerts on those
                            "-kubeResourceNamespacePrefixBlacklist=sam-watchdog",
                        ]
                        + (if configs.kingdom == "prd" then [ "-kubeResourceNamespacePrefixWhitelist=sam-system" ] else [])
                        + samwdconfig.shared_args
                        + [ "-emailFrequency=24h" ],
                        # Please add all new flags and snooze instances to ../configs-sam/watchdog-config.jsonnet
                        volumeMounts: configs.cert_volume_mounts + [
                            configs.cert_volume_mount,
                            configs.kube_config_volume_mount,
                            configs.config_volume_mount,
                        ],
                        env: [
                             configs.kube_config_env,
                        ]
                    }
                ],
                volumes: configs.cert_volumes + [
                    configs.cert_volume,
                    configs.kube_config_volume,
                    configs.config_volume("watchdog"),
                    ],
                nodeSelector: {
                } +
                if configs.kingdom == "prd" then {
                    master: "true"
                } else {
                     pool: configs.estate
                },
            },
            metadata: {
                labels: {
                    name: "watchdog-kuberesources",
                    apptype: "monitoring"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "watchdog-kuberesources"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-kuberesources"
        },
        name: "watchdog-kuberesources"
    }
} else "SKIP"
