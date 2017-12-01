local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
        labels: {
            name: "slb-config-processor",
        },
        name: "slb-config-processor",
        namespace: "sam-system",
    },
    spec: {
        template: {
            metadata: {
                labels: {
                    name: "slb-config-processor",
                    apptype: "control",
                    daemonset: "true",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    configs.maddog_cert_volume,
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.logs_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                 ]),
                containers: [
                    {
                        name: "slb-config-processor",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-config-processor",
                            "--configDir=" + slbconfigs.configDir,
                            "--period=1800s",
                            "--namespace=" + slbconfigs.namespace,
                            "--podstatus=running",
                            "--subnet=" + slbconfigs.subnet,
                            "--k8sapiserver=",
                            "--serviceList=" + slbconfigs.serviceList,
                            "--useVipLabelToSelectSvcs=" + slbconfigs.useVipLabelToSelectSvcs,
                            "--useProxyServicesList=" + slbconfigs.useProxyServicesList,
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                            "--sleepTime=100ms",
                            "--processKnEConfigs=" + slbconfigs.processKnEConfigs,
                            "--kneConfigDir=" + slbconfigs.kneConfigDir,
                            "--kneDomainName=" + slbconfigs.kneDomainName,
                            "--slbConfigInAnnotations=true",
                        ],
                        volumeMounts: configs.filter_empty([
                            configs.maddog_cert_volume_mount,
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.cert_volume_mount,
                            configs.kube_config_volume_mount,
                         ]),
                         env: [
                            configs.kube_config_env,
                        ],
                        securityContext: {
                            privileged: true,
                        },
                    },
                    {
                        name: "slb-cleanup-config-processor",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-cleanup",
                            "--period=1800s",
                            "--logsMaxAge=1h",
                            "--filesDirToCleanup=" + slbconfigs.configDir,
                            "--shouldSkipServiceRecords=true",
                            "--shouldNotDeleteAllFiles=true",
                            "--log_dir=" + slbconfigs.logsDir,
                        ],
                        volumeMounts: configs.filter_empty([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                        ]),
                        securityContext: {
                            privileged: true,
                        },
                    },
                ],
            },
        },
    },
} else "SKIP"
