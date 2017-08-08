local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = import "samimages.jsonnet";
if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-estatesvc",
                        image: samimages.hypersam,
                        command:[
                            "/sam/watchdog",
                            "-role=ESTATESVC",
                            "-watchdogFrequency=10s",
                            "-alertThreshold=300s",
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
                    name: "watchdog-estatesvc",
                    apptype: "monitoring"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "watchdog-estatesvc"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-estatesvc"
        },
        name: "watchdog-estatesvc",
        namespace: "sam-system"
    }
} else "SKIP"
