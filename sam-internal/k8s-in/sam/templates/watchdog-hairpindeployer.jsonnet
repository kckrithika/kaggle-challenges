local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
# This is a hack.  All watchdogs use the shared configMap, but hairpin had a duplicate set of flags
# and is not wired up to the configMap.  We should either pass through flags or have it use the configMap
local samwdconfigmap = import "configs/watchdog-config.jsonnet";
{
    kind: "Deployment",
    spec: {
        strategy: {
              type: "RollingUpdate",
              rollingUpdate: {
                    maxSurge: 0,
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
                        command: [
                            "/sam/watchdog",
                            "-role=HAIRPINDEPLOYER",
                            "-alertThreshold=1h",
                            "-watchdogFrequency=120s",
                            "-emailFrequency=" + (if configs.kingdom == "prd" then "72h" else "24h"),
                            "-deployer-emailFrequency=" + (if configs.kingdom == "prd" then "72h" else "24h"),
                        ]
                        + samwdconfig.shared_args,
                       volumeMounts: configs.filter_empty([
                          configs.sfdchosts_volume_mount,
                          configs.maddog_cert_volume_mount,
                          configs.cert_volume_mount,
                          configs.kube_config_volume_mount,
                          configs.config_volume_mount,
                       ]),
                       env: [
                          configs.kube_config_env,
                       ],
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    configs.config_volume("watchdog"),
                ]),
                nodeSelector: {
                } +
                if configs.kingdom == "prd" then {
                    master: "true",
                } else {
                     pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "watchdog-hairpindeployer",
                    apptype: "monitoring",
                },
               namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-hairpindeployer",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-hairpindeployer",
        },
        name: "watchdog-hairpindeployer",
    },
}
