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
                            "-alertThreshold=1h",
                        ]
                        + (if configs.kingdom == "prd" then [ "-deploymentNamespacePrefixWhitelist=sam-system,csc-sam" ] else [])
                        + samwdconfig.shared_args
                        + [ "-emailFrequency=24h" ],
                        # Please add all new flags and snooze instances to ../configs-sam/watchdog-config.jsonnet
                       volumeMounts: configs.cert_volume_mounts + [
                          configs.cert_volume_mount,
                          configs.kube_config_volume_mount,
                          configs.config_volume_mount,
                       ],
                       env: [
                          configs.kube_config_env
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
                    name: "watchdog-deployment",
                    apptype: "monitoring"
                },
               "namespace": "sam-system"
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
