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
                        name: "watchdog-estatesvc",
                        image: ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/sam/hypersam:sam-0001248-9538cbb,
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
                } +
                if configs.kingdom == "prd" then {
                    master: "true"
                } else {
                     pool: configs.estate
                },
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
