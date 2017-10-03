local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = import "samimages.jsonnet";
# This is a hack.  All watchdogs use the shared configMap, but hairpin had a duplicate set of flags
# and is not wired up to the configMap.  We should either pass through flags or have it use the configMap
local samwdconfigmap = import "configs/watchdog-config.jsonnet";
{
    kind: "Deployment",
    spec: {
        strategy: {
              type: "RollingUpdate",
              rollingUpdate: {
                    maxSurge:   0,
                    maxUnavailable: 1,
              },
         },
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-hairpindeployer",
                        image: samimages.hypersam,
                        command:[
                            "/sam/watchdog",
                            "-role=HAIRPINDEPLOYER",
                            ]
                            + (if configs.estate == "prd-samdev" then [ "-watchdogFrequency=121s" ] else [ "-watchdogFrequency=120s" ])
                            +[ "-alertThreshold=1h",
                            "-deployer-imageName="+samimages.hypersam,
                            "-deployer-funnelEndpoint="+configs.funnelVIP,
                            "-deployer-rcImtEndpoint="+configs.rcImtEndpoint,
                            "-deployer-smtpServer="+configs.smtpServer,
                            "-deployer-sender=sam-alerts@salesforce.com",
                            # TODO: We should kill these flags and use the value from liveConfig
                            "-deployer-recipient="+samwdconfigmap.recipient,
                        ]
                        + samwdconfig.shared_args
                        # [thargrove] 2017-05-05 shared0-samtestkubeapi2-1-prd.eng.sfdc.net is down
                        + (if configs.estate == "prd-samtest" then [ "-snoozedAlarms=hairpinChecker=2017/06/02" ] else [])
                        + (if configs.kingdom == "prd" then [ "-emailFrequency=72h" ] else [ "-emailFrequency=24h" ]),
                        # Please add all new flags and snooze instances to ../configs-sam/watchdog-config.jsonnet
                       volumeMounts: configs.filter_empty([
                          configs.maddog_cert_volume_mount,
                          configs.cert_volume_mount,
                          configs.kube_config_volume_mount,
                          configs.config_volume_mount,
                       ]),
                       env: [
                          configs.kube_config_env,
                       ]
                    }
                ],
                volumes: configs.filter_empty([
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    configs.config_volume("watchdog"),
                ]),
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
                    name: "watchdog-hairpindeployer",
                    apptype: "monitoring"
                },
	       "namespace": "sam-system"
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
