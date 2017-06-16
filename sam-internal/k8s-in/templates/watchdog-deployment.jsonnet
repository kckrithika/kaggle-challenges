local configs = import "config.jsonnet";
local wdconfig = import "samwdconfig.jsonnet";
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
                        + wdconfig.shared_args
                        + wdconfig.shared_args_certs
                        # [thargrove] 2017-05-05 Right now this checker fails for customer apps.  We need to ignore user-* namespaces
                        + (if configs.kingdom == "prd" then [ "-snoozedAlarms=deploymentChecker=2017/06/01" ] else [])
                        + (if configs.kingdom == "prd" then [ "-emailFrequency=72h" ] else [ "-emailFrequency=24h" ]),
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
