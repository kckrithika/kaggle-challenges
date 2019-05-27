local configs = import "config.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = (import "sdnimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

// Free up docker ip addresses in sdc by running this pod as host-network in prd-sdc.
local useHostNetwork = (configs.estate == "prd-sdc");
local ipAddressResourceRequestIfNonHostNetwork = (if !useHostNetwork then configs.ipAddressResourceRequest else {});
local hostNetworkIfEnabled = (if useHostNetwork then { hostNetwork: true } else {});

if !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom) then configs.daemonSetBase("sdn") {
    spec+: {
        template: {
            spec: {
                volumes: [
                    sdnconfigs.sdn_logs_volume,
                ],
                containers: [
                    {
                        name: "sdn-cleanup",
                        image: sdnimages.hypersdn,
                        command: [
                            "/sdn/sdn-cleanup",
                            "--period=1440m",
                            "--logsMaxAge=48h",
                            "--filesDirToCleanup=" + sdnconfigs.logFilePath,
                            "--shouldNotDeleteAllFiles=false",
                            sdnconfigs.logDirArg,
                            sdnconfigs.logToStdErrArg,
                            sdnconfigs.alsoLogToStdErrArg,
                        ],
                        volumeMounts: [
                            sdnconfigs.sdn_logs_volume_mount,
                        ],
                        securityContext: {
                            privileged: true,
                        },
                    } + ipAddressResourceRequestIfNonHostNetwork,
                ],
            } + hostNetworkIfEnabled,
            metadata: {
                labels: {
                    name: "sdn-cleanup",
                    apptype: "control",
                    daemonset: "true",
                } + (if configs.kingdom != "prd" &&
                        configs.kingdom != "xrd" then
                        configs.ownerLabel.sdn else {}),
                namespace: "sam-system",
            },
        },
        updateStrategy: {
            type: "RollingUpdate",
            rollingUpdate: {
            maxUnavailable: "25%",
            },
        },
    },
    metadata: {
        labels: {
            name: "sdn-cleanup",
        },
        name: "sdn-cleanup",
        namespace: "sam-system",
    },
} else "SKIP"
