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
                        name: "watchdog-hairpindeployer",
                        image: configs.watchdog,
                        command:[
                            "/sam/watchdog",
                            "-role=HAIRPINDEPLOYER",
                            "-watchdogFrequency=120s",
                            "-alertThreshold=300s",
                            "-deployer-imageName="+configs.watchdog,
                            "-deployer-funnelEndpoint="+configs.funnelVIP,
                            "-deployer-rcImtEndpoint="+configs.rcImtEndpoint,
                            "-deployer-smtpServer="+configs.smtpServer,
                            "-deployer-sender="+configs.watchdog_emailsender,
                            "-deployer-recipient="+configs.watchdog_emailrec,
                        ]
                        + wdconfig.shared_args
                        + wdconfig.shared_args_certs
                        # [thargrove] 2017-05-05 shared0-samtestkubeapi2-1-prd.eng.sfdc.net is down
                        + (if configs.estate == "prd-samtest" then [ "-snoozedAlarms=hairpinChecker=2017/06/02" ] else [])
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
                    name: "watchdog-hairpindeployer",
                    apptype: "monitoring"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "watchdog-hairpindeployer"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-hairpindeployer"
        },
        name: "watchdog-hairpindeployer"
    }
}
