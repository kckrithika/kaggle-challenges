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
                        + samwdconfig.shared_args_certs
                        + [ "-emailFrequency=24h" ],
                        volumeMounts: [
                            samwdconfig.cert_volume_mount,
                            samwdconfig.kube_config_volume_mount,
                        ],
                        env: [
                             {
                                "name": "KUBECONFIG",
                                "value": configs.configPath
                             }
                        ]
                    }
                ],
                volumes: [
                    samwdconfig.cert_volume,
                    samwdconfig.kube_config_volume,
                    ],
                nodeSelector: {
                    pool: configs.estate
                } +
                if configs.estate == "prd-samtest" then {
                    // In the case of samtest, we deploy only to master so we can assimilate the control-estate
                    // minions to consumer minions and extrapolate the required permissions for those nodes.
                    // When the testing of authorization is done, we can move back to normal (any node of the control-estate)
                    master: "true"
                } else {}
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
