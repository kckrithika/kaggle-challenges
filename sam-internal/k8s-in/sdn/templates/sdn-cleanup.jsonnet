local configs = import "config.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = (import "sdnimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

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
                        [if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then "resources"]: configs.ipAddressResource,
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
                    },
                ],
            },
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
    },
    metadata: {
        labels: {
            name: "sdn-cleanup",
        },
        name: "sdn-cleanup",
        namespace: "sam-system",
    },
} else "SKIP"
