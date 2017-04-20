local configs = import "config.jsonnet";
local wdconfig = import "wdconfig.jsonnet";

if configs.estate == "prd-sam" || configs.estate == "phx-sam" || configs.estate == "frf-sam" || configs.estate == "par-sam" || configs.estate == "dfw-sam" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-apiserverlb",
                        image: configs.watchdog,
                        command:[
                            "/sam/watchdog",
                            "-role=APISERVERLB",
                            "-watchdogFrequency=60s",
                            "-alertThreshold=60s",
                            "-emailFrequency=12h",
                        ]
                        + wdconfig.shared_args
                        + wdconfig.shared_args_certs,
                        volumeMounts: [
                                  wdconfig.cert_volume_mount
                        ],
                    }
                ],
                volumes: [
                    wdconfig.cert_volume
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
                    name: "watchdog-apiserverlb",
                    apptype: "monitoring"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "watchdog-apiserverlb"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-apiserverlb"
        },
        name: "watchdog-apiserverlb"
    }
} else "SKIP"
