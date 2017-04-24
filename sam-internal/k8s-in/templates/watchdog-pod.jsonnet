local configs = import "config.jsonnet";
local wdconfig = import "wdconfig.jsonnet";

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
                        image: configs.watchdog,
                        command:[
                            "/sam/watchdog",
                            "-role=POD",
                            "-watchdogFrequency=60s",
                            "-alertThreshold=300s",
                            "-emailFrequency=24h",
                        ]
                        + wdconfig.shared_args
                        + wdconfig.shared_args_certs
                        + if configs.estate == "prd-sam" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.kingdom == "phx"
                            then [ "-snoozedAlarms=podUpTimeChecker=2017/05/02" ] else  [],
                        volumeMounts: [
                            wdconfig.cert_volume_mount,
                            wdconfig.kube_config_volume_mount,
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
                    wdconfig.cert_volume,
                    wdconfig.kube_config_volume,
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
