local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = import "samimages.jsonnet";
if configs.kingdom == "prd" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-proxy",
                        image: samimages.hypersam,
                        command:[
                            "/sam/watchdog",
                            "-role=K8SPROXY",
                            "-k8sproxyEndpoint=http://localhost:40000",
                            "-watchdogFrequency=10s",
                            "-alertThreshold=300s",
                            "-emailFrequency=48h",
                        ]
                        + samwdconfig.shared_args,
                        # Please add all new flags and snooze instances to ../configs-sam/watchdog-config.jsonnet
                        volumeMounts: [
                            configs.config_volume_mount,
                        ],
                    }
                ],
                volumes: [
                    configs.config_volume("watchdog"),
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
                    name: "watchdog-proxy",
                    apptype: "monitoring"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "watchdog-proxy"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-proxy"
        },
        name: "watchdog-proxy"
    }
} else "SKIP"
