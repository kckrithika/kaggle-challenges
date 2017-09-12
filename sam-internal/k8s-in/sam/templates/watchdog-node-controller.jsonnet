local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = import "samimages.jsonnet";
if configs.kingdom == "NOTDEPLOYED" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-node-controller",
                        image: samimages.hypersam,
                        command:[
                            "/sam/watchdog",
                            "-role=NODECONTROLLER",
                            "-watchdogFrequency=10s",
                            "-alertThreshold=300s",
                        ]
                        + samwdconfig.shared_args,
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
                    name: "watchdog-node-controller",
                    apptype: "monitoring"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "watchdog-node-controller"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-node-controller"
        },
        name: "watchdog-node-controller",
        namespace: "sam-system"
    }
} else "SKIP"
