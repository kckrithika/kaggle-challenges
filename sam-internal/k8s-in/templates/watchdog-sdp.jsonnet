local configs = import "config.jsonnet";
local wdconfig = import "wdconfig.jsonnet";

if configs.kingdom == "prd" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-sdp",
                        image: configs.watchdog,
                        command:[
                            "/sam/watchdog",
                            "-role=SDP",
                            "-sdpEndpoint=http://localhost:39999",
                            "-watchdogFrequency=10s",
                            "-alertThreshold=300s",
                            "-emailFrequency=12h",
                        ]
                        + wdconfig.shared_args
                    }
                ],
                nodeSelector: {
                    pool: configs.estate
                }
            },
            metadata: {
                labels: {
                    name: "watchdog-sdp",
                    apptype: "monitoring"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "watchdog-sdp"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-sdp"
        },
        name: "watchdog-sdp"
    }
} else "SKIP"
