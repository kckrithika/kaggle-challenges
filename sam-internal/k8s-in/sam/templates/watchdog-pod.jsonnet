local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = import "samimages.jsonnet";
{
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-pod",
                        image: samimages.hypersam,
                        command:[
                            "/sam/watchdog",
                            "-role=POD",
                            "-watchdogFrequency=60s",
                            "-alertThreshold=300s",
                            "-maxUptimeSampleSize=5",
                            # We dont want to report on broken hairpin pods, since hairpin already alerts on those
                            "-podNamespacePrefixBlacklist=sam-watchdog",
                        ]
                        + (if configs.kingdom == "prd" then [ "-podNamespacePrefixWhitelist=sam-system" ] else [])
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
                    name: "watchdog-pod",
                    apptype: "monitoring"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "watchdog-pod"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-pod"
        },
        name: "watchdog-pod"
    }
}
