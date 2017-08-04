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
                        name: "watchdog-deployment",
                        image: samimages.hypersam,
                        command:[
                            "/sam/watchdog",
                            "-role=DEPLOYMENT",
                            "-watchdogFrequency=10s",
                            "-alertThreshold=300s",
                        ]
                        + (if configs.kingdom == "prd" then [ "-deploymentNamespacePrefixWhitelist=sam-system,csc-sam" ] else [])
                        + samwdconfig.shared_args
                        + samwdconfig.shared_args_certs
                        + [ "-emailFrequency=24h" ],
                       volumeMounts: [
                          configs.cert_volume_mount,
                          configs.kube_config_volume_mount,
                          configs.config_volume_mount,
                       ],
                       env: [
                          configs.kube_config_env
                       ]
                    }
                ],
                volumes: [
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
                    name: "watchdog-deployment",
                    apptype: "monitoring"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "watchdog-deployment"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-deployment"
        },
        name: "watchdog-deployment"
    }
}
